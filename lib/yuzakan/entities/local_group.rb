class LocalGroup < Hanami::Entity
  def name
    Hanami.logger.warn('call LocalGroup#name')
    groupname
  end
end
