module ActiveMigration
  # The keymapper allows you to serialize and deserialize primary keys.  This is useful in maintaining foreign key
  # relationships, if you choose not to migrate the primary key.
  #
  # To serialize the keys you simply:
  #
  #   write_key_map true
  #
  #
  # To deserialize the key for a foreign key you can specifiy the keymap as the third element:
  #
  #   map [['product_id','product_id',:products]]
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
          attr_accessor :map_keys

          # Tells ActiveMigration to serialize the primary key of the legacy model.
          #
          #   write_key_map true
          #
          def write_key_map(map_keys)
            @map_keys = map_keys
          end
          alias map_keys= write_key_map
        end
      end
    end

    def run_with_key_mapping #:nodoc:
      run_without_key_mapping
      write_key_map(self.storage_path, self.class.legacy_model.to_s.demodulize.tableize) if self.class.map_keys
    end

    def migrate_field_with_key_mapping #:nodoc:
      unless @mapping[2].nil?
        load_keymap(@mapping[2].to_s)
        key = mapped_key(@mapping[2], @legacy_record.instance_eval(@mapping[0]))
        @legacy_record.__send__(@mapping[0] + '=', key)
      end
      migrate_field_without_key_mapping
    end

    def save_active_record_with_key_mapping #:nodoc:
      save_active_record_without_key_mapping
      map_primary_key(@active_record.id, @legacy_record.id) if self.class.map_keys
    end

    def map_primary_key(active_id, legacy_id) #:nodoc:
      @key_mappings ||= {}
      @key_mappings[legacy_id] = active_id
    end

    def write_key_map(data_path, filename) #:nodoc:
      File.open(File.join(data_path, (filename + "_map.yml")), 'w') do |file|
        file.write @key_mappings.to_yaml
      end
      logger.info("#{self.class.to_s} wrote keymap successfully to #{File.join(data_path, (filename + "_map.yml"))}")
    end

    # Lazy loader...
    def load_keymap(map) #:nodoc:
      @maps ||= Hash.new
      if @maps[map].nil?
        @maps[map] = YAML.load(File.open(File.join(self.storage_path, map.to_s + "_map.yml")))
        logger.debug("#{self.class.to_s} lazy loaded #{map} successfully.")
      end
    end

    # Returns the deserialized mapped key when provided with the former key.
    #
    #  mapped_key(:products, 2)
    #
    def mapped_key(map, key)
      load_keymap(map.to_s)
      @maps[map.to_s][key]
    end

  end
end
