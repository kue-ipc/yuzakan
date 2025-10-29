# frozen_string_literal: true

Hanami.app.register_provider(:adapter_map) do
  prepare do
    register "adapter_map", {}
  end

  start do
    [
      [Hanami.app_path.dirname.parent / "lib" / "yuzakan" / "adapters", ""],
      [Hanami.app_path.dirname.parent / "vendor" / "adapters", "vendor."],
    ].each do |path, prefix|
      next unless path.directory?

      path.each_child do |child|
        next unless child.to_path.end_with?(".rb", ".so")

        require_relative child.to_path
        name = child.basename(".*").to_s
        class_name = target["inflector"].camelize(name)
        klass =
          [Yuzakan::Adapters, defined?(Adapters) && Adapters, Object]
            .comapct
            .find { |m| m.const_defined?(class_name) }
            &.const_get(class_name)
        raise "Adapter class #{class_name} not found in #{child}" if klass.nil?

        target["adapter_map"].store(prefix + name, {name:, class: klass})
      end
    end
  end

  stop do
    target["adapter_map"].clear
  end
end
