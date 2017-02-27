module GlobalConfig
  module Store
    macro extended
      {%
        module_or_class = @type.class.name.ends_with?(":Module") ? "module".id : "class".id
      %}

      macro global_config(name, env = nil)
        \{%
          name = name.id
          ex = "No#{name.camelcase}".id
        \%}

        {{module_or_class}} ::{{@type}}
          class \{{ex}} < ::Exception
            def initialize
              super "No configuration: \{{name}}"
            end
          end

          \{% if env %}
            @@\{{name}} : String? = ::GlobalConfig.env?(\{{env.map{|i| i.id.stringify}.splat}})
          \{% else %}
            @@\{{name}} : String?
          \{% end %}

          @@global_config_per_fiber__\{{name}} = {} of ::UInt64 => ::String?

          def self.\{{name}}
            if v = \{{name}}?
              v
            else
              raise \{{ex}}.new
            end
          end

          def self.\{{name}}?
            @@global_config_per_fiber__\{{name}}[::Fiber.current.object_id]? || @@\{{name}}
          end

          def self.\{{name}}=(value : String)
            @@\{{name}} = value
          end

          def self.\{{name}}(value : String, &block : ->)
            current = @@global_config_per_fiber__\{{name}}[::Fiber.current.object_id]?
            begin
              @@global_config_per_fiber__\{{name}}[::Fiber.current.object_id] = value
              yield
            ensure
              @@global_config_per_fiber__\{{name}}[::Fiber.current.object_id] = current
            end
          end
        {{"end".id}}
      end

      macro global_config_context(name, *values)
        \{%
          name = name.id
        \%}

        {{module_or_class}} ::{{@type}}
          def self.\{{name}}(\{{values.map{|i| "#{i.id} : ::String".id}.splat}})
            %current = \{{values.map{|i| "@@global_config_per_fiber__#{i.id}[::Fiber.current.object_id]?".id}}}
            begin
              \{% for e, i in values %}
                @@global_config_per_fiber__\{{e.id}}[::Fiber.current.object_id] = \{{e.id}}
              \{% end %}
              yield
            ensure
              \{% for e, i in values %}
                @@global_config_per_fiber__\{{e.id}}[::Fiber.current.object_id] = %current[\{{i}}]
              \{% end %}
            end
          end

          def self.\{{name}}!(\{{values.map{|i| "#{i.id} : ::String? = nil".id}.splat}})
            %current = \{{values.map{|i| "@@global_config_per_fiber__#{i.id}[::Fiber.current.object_id]?".id}}}
            begin
              \{% for e, i in values %}
                @@global_config_per_fiber__\{{e.id}}[::Fiber.current.object_id] = \{{e.id}} if \{{e.id}}
              \{% end %}
              yield
            ensure
              \{% for e, i in values %}
                @@global_config_per_fiber__\{{e.id}}[::Fiber.current.object_id] = %current[\{{i}}]
              \{% end %}
            end
          end
        {{"end".id}}
      end
    end
  end
end
