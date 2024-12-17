# frozen_string_literal: true

Hanami.app.register_provider(:adapters) do
  prepare do
    register "adapters", {}
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
        target["adapters"][prefix + name] =
          Yuzakan::Adapters.const_get(target["inflector"].camelize(name))
      end
    end
  end

  stop do
    target["adapters"].clear
  end
end
