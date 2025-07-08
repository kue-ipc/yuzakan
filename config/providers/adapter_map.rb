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
      path.each_child do |child|
        next unless child.to_path.end_with?(".rb", ".so")

        require_relative child.to_path
        name = child.basename(".*").to_s
        class_name = target["inflector"].camelize(name)
        target["adapter_map"].store(prefix + name, Yuzakan::Adapters.const_get(class_name))
      end
    end
  end

  stop do
    target["adapter_map"].clear
  end
end
