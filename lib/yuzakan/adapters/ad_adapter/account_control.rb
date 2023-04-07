# frozen_string_literal: true

# AD Account Control
# https://learn.microsoft.com/ja-jp/troubleshoot/windows-server/identity/useraccountcontrol-manipulate-account-properties

require_relative '../ldap_adapter'

module Yuzakan
  module Adapters
    class AdAdapter < LdapAdapter
      class AccountControl
        module Flag
          SCRIPT                         = 0x0001 # 1
          ACCOUNTDISABLE                 = 0x0002 # 2
          HOMEDIR_REQUIRED               = 0x0008 # 8
          LOCKOUT                        = 0x0010 # 16
          PASSWD_NOTREQD                 = 0x0020 # 32
          PASSWD_CANT_CHANGE             = 0x0040 # 64
          ENCRYPTED_TEXT_PWD_ALLOWED     = 0x0080 # 128
          TEMP_DUPLICATE_ACCOUNT         = 0x0100 # 256
          NORMAL_ACCOUNT                 = 0x0200 # 512
          INTERDOMAIN_TRUST_ACCOUNT      = 0x0800 # 2048
          WORKSTATION_TRUST_ACCOUNT      = 0x1000 # 4096
          SERVER_TRUST_ACCOUNT           = 0x2000 # 8192
          DONT_EXPIRE_PASSWORD           = 0x10000 # 65536
          MNS_LOGON_ACCOUNT              = 0x20000 # 131072
          SMARTCARD_REQUIRED             = 0x40000 # 262144
          TRUSTED_FOR_DELEGATION         = 0x80000 # 524288
          NOT_DELEGATED                  = 0x100000 # 1048576
          USE_DES_KEY_ONLY               = 0x200000 # 2097152
          DONT_REQ_PREAUTH               = 0x400000 # 4194304
          PASSWORD_EXPIRED               = 0x800000 # 8388608
          TRUSTED_TO_AUTH_FOR_DELEGATION = 0x1000000 # 16777216
          PARTIAL_SECRETS_ACCOUNT        = 0x04000000 # 67108864
        end
        DEFAULT_USER_FLAGS = Flag::NORMAL_ACCOUNT | Flag::DONT_EXPIRE_PASSWORD

        ATTRIBUTE_NAME = 'userAccountControl'

        include Enumerable

        def initialize(argv = DEFAULT_USER_FLAGS)
          case argv
          when Integer
            @flags = argv
          when Array
            @flags = 0
            argv.each { |flag| @flags |= flag }
          else
            raise ArgumentError, "Invalid flags: #{argv}"
          end
        end

        def intersection(other)
          new(@flags & other.to_i)
        end
        alias & intersection

        def union(other)
          new(@flags | other.to_i)
        end
        alias + union
        alias | union

        def ^(other)
          new(@flags ^ other.to_i)
        end

        def difference(other)
          new(@flags & ~other.to_i)
        end
        alias - difference

        def add(other)
          @flags |= other.to_i
          self
        end
        alias << add
        alias merge add

        def delete(other)
          @flags &= ~other.to_i
          self
        end
        alias subtract delete

        def replace(other)
          @flags = other.to_i
          self
        end

        def clear
          @flags = 0
          self
        end

        def clone
          new(@flags)
        end
        alias dup clone

        def ==(other)
          @flags == other.to_i
        end

        def include?(other)
          @flags.allbits?(other.to_i)
        end
        alias member? include?
        alias === include?
        alias superset? include?

        def subset?(other)
          other.to_i.allbits?(@flags)
        end

        def proper_subset?(other)
          return false if self == other

          subset?(other)
        end

        def proper_superset?(other)
          return false if self == other

          superset?(other)
        end

        def disjoint?(other)
          (@flags & other.to_i).zero?
        end

        def intersect?(other)
          !disjoint?(other)
        end

        def empty?
          @flags.zero?
        end

        def each
          return to_enum unless block_given?

          n = 1
          while n <= @flags
            yield n if @flags.anybits?(n)
            n <<= 1
          end
        end

        def to_i
          @flags
        end

        def to_s
          '0x%04X' % to_i
        end

        def inspect
          "#<#{self.class.name}: #{self}>"
        end

        Flag.constants(false).each do |name|
          flag = Flag.const_get(name)
          method_name = name.downcase
          define_method(method_name) do
            include?(flag)
          end
          alias_method("#{method_name}?", method_name)
          define_method("#{method_name}=") do |bool|
            if bool
              add(flag)
            else
              delete(flag)
            end
          end
        end
      end
    end
  end
end
