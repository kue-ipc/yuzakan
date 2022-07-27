class Group < Hanami::Entity
  def name
    Hanami.logger.warn('call Group#name')
    groupname
  end
end
