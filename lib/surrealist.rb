# frozen_string_literal: true

require_relative 'surrealist/class_methods'
require_relative 'surrealist/instance_methods'
require_relative 'surrealist/boolean'
require 'multi_json'

# Main module that provides the +schema+ class method and +surrealize+ instance method.
module Surrealist
  # Error class for classes without defined +schema+.
  class UnknownSchemaError < RuntimeError; end

  # Error class for classes with +schema+ defined not as a hash.
  class InvalidSchemaError < RuntimeError; end

  # Error class for +NoMethodError+.
  class UndefinedMethodError < RuntimeError; end

  # Error class for failed type-checks.
  class InvalidTypeError < TypeError; end

  # @param [Class] base class to include/extend +Surrealist+.
  def self.included(base)
    base.extend(Surrealist::ClassMethods)
    base.include(Surrealist::InstanceMethods)
  end

  # Dumps the object's methods corresponding to the schema
  # provided in the object's class and type-checks the values.
  #
  # @param [Object] instance of a class that has +Surrealist+ included.
  #
  # @return [String] a json-formatted string corresponding to the schema
  #   provided in the object's class. Values will be taken from the return values
  #   of appropriate methods from the object.
  #
  # @raise +Surrealist::UnknownSchemaError+ if no schema was provided in the object's class.
  #
  # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
  #
  # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
  #   does not have a corresponding method on the object.
  #
  # @example Define a schema and surrealize the object
  #   class User
  #     include Surrealist
  #
  #     schema do
  #       {
  #         name: String,
  #         age: Integer,
  #       }
  #     end
  #
  #     def name
  #       'Nikita'
  #     end
  #
  #     def age
  #       23
  #     end
  #   end
  #
  #   User.new.surrealize
  #   # => "{\"name\":\"Nikita\",\"age\":23}"
  #   # For more examples see README
  def self.surrealize(instance)
    ::MultiJson.dump(build_schema(instance))
  end

  # Builds hash from schema provided in the object's class and type-checks the values.
  #
  # @param [Object] instance of a class that has +Surrealist+ included.
  #
  # @return [Hash] a hash corresponding to the schema
  #   provided in the object's class. Values will be taken from the return values
  #   of appropriate methods from the object.
  #
  # @raise +Surrealist::UnknownSchemaError+ if no schema was provided in the object's class.
  #
  # @raise +Surrealist::InvalidTypeError+ if type-check failed at some point.
  #
  # @raise +Surrealist::UndefinedMethodError+ if a key defined in the schema
  #   does not have a corresponding method on the object.
  #
  # @example Define a schema and surrealize the object
  #   class User
  #     include Surrealist
  #
  #     schema do
  #       {
  #         name: String,
  #         age: Integer,
  #       }
  #     end
  #
  #     def name
  #       'Nikita'
  #     end
  #
  #     def age
  #       23
  #     end
  #   end
  #
  #   User.new.build_schema
  #   # => { name: 'Nikita', age: 23 }
  #   # For more examples see README
  def self.build_schema(instance)
    schema = instance.__surrealist_schema rescue nil

    if schema.nil?
      raise Surrealist::UnknownSchemaError, "Can't serialize #{instance.class} - no schema was provided."
    end

    Builder.call(schema: schema, instance: instance)
  end
end