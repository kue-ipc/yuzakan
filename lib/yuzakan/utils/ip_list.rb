# # frozen_string_literal: true

# require 'ipaddress'

# module Yuzakan
#   module Utils
#     module IPList
#       module_function

#       def str_to_ips(str, sep = /[,\s]\s*/)
#         str.split(sep).map(&method(:IPAddress))
#       end

#       def ips_to_str(ips, sep = "\n")
#         ips.map(&:to_string).join(sep)
#       end

#       def include_net?(addr, networks)\
#         addr = IPAddress(addr) if addr.is_a?(String)
#         networks = str_to_ips(networks) if networks.is_a?(String)
#         networks.any? do |net|
#           # 同じクラスでないとinclude?でのチェックでエラーになる。
#           net.class == addr.class && net.include?(addr)
#         end
#       end

#       def ips_str_normalize(str)
#         ips_to_str(str_to_ips(str))
#       end
#     end
#   end
# end
