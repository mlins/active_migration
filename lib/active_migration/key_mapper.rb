module ActiveMigration
  # The keymapper allows you to serialize and deserialize primary keys.  This is useful in maintaining foreign key
  # relationships, if you choose not to migrate the primary key.
  #
  # To serialize the keys you simply:
  #
  #   set_map_primary_key true
  #
  # To deserialize the keys and map them you first need to load the maps, using the plural form of your migration.
  # If you had a Product, then you would load :products :
  #
  #   set_use_maps  :products,
  #
  # To deserialize the key for a foreign key you can:
  #
  #   set_mappings  [
  #                 ['product_id',  'product_id',   :map]
  #                 ]
  #
  # If you'd like to access the key from a callback or anywhere outside the mappings array, you can use:
  #
  #   mapped_key(:products, old_key)
  #
  module KeyMapper

    # The path to store the serialized(YAML) keys.
    #
    # Defaults to '/tmp'
    #
    mattr_accessor :storage_path
    self.storage_path = '/tmp'

    def self.included(base)
      base.class_eval do
        alias_method_chain :run, :key_mapping
        alias_method_chain :migrate_field, :key_mapping
        alias_method_chain :save_active_record, :key_mapping
        class << self
          attr_accessor :map_primary_key, :maps_to_load

          # Tells ActiveMigration to serialize the primary key of the legacy model.
          #
          #   set_map_primary_key true
          #
          def set_map_primary_key(map_primary_key)
            @map_primary_key = map_primary_key
          end
          alias map_primary_key= map_primary_key

          # Lets ActiveMigration know what maps to load.
          #
          #   set_use_maps  :products
          #
          def set_use_maps(*maps)
            maps.each do |map|
              @maps_to_load ||= []
              @maps_to_load << map.to_s
            end
          end
        end
      end
    end

    def run_with_key_mapping #:nodoc:
      load_maps if self.class.maps_to_load
      run_without_key_mapping
      write_key_map(self.storage_path, self.class.legacy_model.to_s.demodulize.tableize) if self.class.map_primary_key
    end

    def migrate_field_with_key_mapping(active_record, legacy_record, mapping) #:nodoc:
      eval("legacy_record.#{mapping[0]} = mapped_key(mapping[2], legacy_record.#{mapping[0]})") unless mapping[2].nil?
      migrate_field_without_key_mapping(active_record, legacy_record, mapping)
    end

    def save_active_record_with_key_mapping(active_record, legacy_record) #:nodoc:
      save_active_record_without_key_mapping(active_record, legacy_record)
      map_primary_key(active_record.id, legacy_record.id) if self.class.map_primary_key
    end

    def map_primary_key(active_id, legacy_id) #:nodoc:
      @key_mappings ||= {}
      @key_mappings[legacy_id] = active_id
    end

    def write_key_map(data_path, filename) #:nodoc:
      File.open(File.join(data_path, (filename + "_map.yml")), 'w') do |file|
        file.write @key_mappings.to_yaml
      end
    end

    def load_maps #:nodoc:
      @maps ||= Hash.new
      self.class.maps_to_load.each do |map|
        @maps[map] = YAML.load(File.open(File.join(self.storage_path, map + "_map.yml")))
      end
    end

    # Returns the deserialized mapped key when provided with the former key.
    #
    #  mapped_key(:products, 2)
    #
    def mapped_key(map, key)
      @maps[map.to_s][key]
    end

  end
end
