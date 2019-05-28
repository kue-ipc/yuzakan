
require 'securerandom'
require 'net/ldap'

# adapter
#
# CRUD
# create(name, attrs)
# read(name) -> attrs
# update(name, attrs)
# delete(name)
#
# search(name)
# chaneg_passwd(user, pass)
# auth(name, pass)
#

module Yuzakan
  module Adapters
    class LdapAdapter
      NAME = 'LDAP'
      PARAMATERS = {
        server: {
          name: 'LDAPサーバーURL',
          description: 'LDAPサーバーのURLです。ldaps://サーバー名/',
          type: :string,
          required: true,
        },
        uri: {
          name: 'LDAPサーバーURL',
          description: 'LDAPサーバーのURLです。ldaps://サーバー名/',
          type: :string,
          required: true,
        },
        bind_user: {
          name: 'LDAPサーバーURL',
          type: :string,
          required: true,
        },
        bind_pass: {
          name: 'LDAPサーバーURL',
          type: :secret,
          required: true,
        },
        user_name_attr: {
          name: 'ユーザー名の属性',
          type: :secret,
          required: true,
        },
        user_base: {
          name: 'ユーザー検索のベース',
          description: 'ユーザー検索を行うときのツリーベースです。指定しない場合はLDAPサーバーのベースから検索します。',
          type: :string,
          required: false,
        },
        user_scope: {
          name: 'ユーザー検索のスコープ',
          description: 'ユーザー検索を行うときのスコープです。デフォルトは sub です。',
          type: :string,
          required: true,
          default: 'sub',
          list: %w[base one sub],
        },
        user_filter: {
          name: 'ユーザー検索のフィルター',
          description: 'ユーザー検索を行うときのフィルターです。LDAPの形式で指定します。何も指定しない場合は(objectclass=*)',
          type: :string,
          required: false,
        },
      }
    end

    def initalize(params)
      @params = params
    end

    def create(name)
      raise NotImplementError
    end

    def read(name)
      raise NotImplementError
    end

    def udpate(name)
      raise NotImplementError
    end

    def delete(name)
      raise NotImplementError
    end




    def ldap_connect
      opts = {
        host: @params[:host],
        port: @params[:port],
        base: @params[:base],
        auth: {
          method: @params[:auth_method],
          username: @params[:bind_user],
          password: @params[:bind_pass],
        },
      }

      opts[:encryption] = :simple_tls if @params[:tls]

      Net::LDAP.open(opts) do |ldap|
        yield ldap
      end
    end

    def search_user(ldap, name)
      opts = {}
      opts[:base] = @params[:user_base] if @params[:user_base]
      opts[:scop] =
        case @params[:user_scope]
        when 'base'
          Net::LDAP::SearchScope_BaseObject
        when 'one'
          Net::LDAP::SearchScope_SingleLevel
        when 'sub'
          Net::LDAP::SearchScope_WholeSubtree
        else
          raise 'Invalid scope'
        end

      common_filter =
        if @params[:user_filter]
          Net::LDAP::Filter.construct(@params[:user_filter])
        else
          Net::LDAP::Filter.pres('objectclass')
        end

      opts[:filter] = common_filter &
        Net::LDAP::Filter.eq(@params[:user_name_attr], name)

      result_entry = nil
      ldap.search(opts) do |entry|
        raise 'Duplicated user name' if result_entry
        result_entry = entry
      end
      return result_entry
    end

    def ldap_auth(name, pass)
      ldap_connect do |ldap|
        dn = get_user_dn(ldap, name)
        ldap.bind_as(name)
      end
      opts = {
        host: @params[:host],
        port: @params[:port],
        base: @params[:base],
        auth: {
          method: @params[:auth_method],
          username: name,
          password: pass,
        }
      }

      opts[:encryption] = :simple_tls if @params[:tls]

      ldap Net::LDAP.new(opts)
      if ldap.bind
      end
    end

    def change_password(user, pass)
      ldap_connect do |ldap|
        user_dn = get_user_dn(user.name)
        ldap.modify(
          dn: user_dn,
          operations: [
            [:repalce, :passwd, generate_crypt(pass)]
          ]
        )
      end
    end

    # 現在のところ CRYPT-MD5のみ実装
    # slappasswd -h '{CRYPT}' -c '$1$%.8s'
    # $1$vuIZLw8r$d9mkddv58FuCPxOh6nO8f0
    def generate_crypt(str)
      salt = '$1$' + SecureRandom.base64(6).gsub('+', '.')
      '{CRYPT}' + str.crypt(salt)
    end

    def lock_password(str)
      if (m = /\A({[A-Z]+})(.*)\z/.match(str))
        m[1] + '!' + m[2]
      else
        # 不正なパスワード
        '{!}!'
      end
    end

    def unlock_password(str)
      if (m = /\A({[A-Z]+})!(.*)\z/.match(str))
        m[1] + m[2]
      else
        str
      end
    end
  end
end
