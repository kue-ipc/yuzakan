# frozen_string_literal: true

Hanami.app.register_provider(:adapter_repo) do
  start do
    adapter_repo = Yuzakan::AdapterRepo.new

    adapter_repo.set!("local", class: Yuzakan::Adapters::Local)
    adapter_repo.set!("ldap", class: Yuzakan::Adapters::Ldap)
    adapter_repo.set!("ad", class: Yuzakan::Adapters::AD)
    adapter_repo.set!("posix_ldap", class: Yuzakan::Adapters::PosixLdap)
    adapter_repo.set!("samba_ldap", class: Yuzakan::Adapters::SambaLdap)
    adapter_repo.set!("google", class: Yuzakan::Adapters::Google)
    # adapter_repo.set!("microsoft", class: Yuzakan::Adapters::Microsoft) # not yet implemented
    adapter_repo.set!("test", class: Yuzakan::Adapters::Test) if Hanami.env?(:development, :test)
    adapter_repo.set!("dummy", class: Yuzakan::Adapters::Dummy) if Hanami.env?(:test)
    adapter_repo.set!("mock", class: Yuzakan::Adapters::Mock) if Hanami.env?(:test)

    vender_adapter_path = Hanami.app_path.dirname.parent / "vendor" / "adapters"
    if vender_adapter_path.directory?
      vender_adapter_path.each_child do |child|
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

        adapter_repo.set!(prefix + name, class: klass)
      end
    end

    register "adapter_repo", adapter_repo
  end
end
