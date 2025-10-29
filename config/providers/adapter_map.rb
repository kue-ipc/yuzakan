# frozen_string_literal: true

Hanami.app.register_provider(:adapter_map) do
  prepare do
    register "adapter_map", {}
  end

  start do
    [
      Hanami.app_path.dirname.parent / "lib" / "yuzakan" / "adapters",
      Hanami.app_path.dirname.parent / "vendor" / "adapters",
    ].each do |path|
      path.each_child do |child|
        next unless child.to_path.end_with?(".rb", ".so")

        require_relative child.to_path
        name = child.basename(".*").to_s
        class_name = target["inflector"].camelize(name)
        klass = Yuzakan::Adapters.const_get(class_name)
        target["adapter_map"].store(klass.adapter_name, klass)
      end
    end
  end

  stop do
    target["adapter_map"].clear
  end
end
