# frozen_string_literal: true

module API
  module Actions
    module Groups
      class Sync < API::Action
        def handle(request, response)
        end

        # all
        def get_groups_all
          all_groups = []
          all_groups.concat(group_repo.all.map(&:name))
          @service_repository.ordered_all_with_adapter_by_operation(:group_read).each do |service|
            all_groups.concat(service.group_list)
          end
          all_groups.uniq!
          all_groups.sort!
          {
            groups: all_groups.map { |name| {name: name} },
            headers: {"Content-Location" => routes.path(:groups, all: true)},
          }
        end


        private def get_groups(groupnames)
          group_entities = @group_repository.all_by_name(groupnames).to_h do |group|
            [group.name, group]
          end
          groupnames.map do |groupname|
            group_entities[groupname] || get_sync_group(groupname)
          end
        end

        # sync on
        def get_groups_from_service(params)
          params = params.to_h

          if params.key?(:order) && !params[:key].start_with?("name")
            # nameに対する順序以外は無視される。
            params = params.except(:order)
          end

          groups_services = Hash.new { |hash, key| hash[key] = [] }
          query = ("*#{params[:query]}*" if params[:query]&.size&.positive?)

          @service_repository.ordered_all_with_adapter_by_operation(:group_read).each do |service|
            # プライマリグループがある場合のみ検索
            next if params[:primary_only] && !service.has_primary_group?

            items =
              if query
                service.group_search(query)
              else
                service.group_list
              end
            items.each { |item| groups_services[item] << service.name }
          end
          all_items = groups_services.keys

          # prohibitedなグループは隠す
          all_items -= @group_repository.filter(prohibited: true).map(:name) if params[:hide_prohibited]

          # プロバイダーにないグループもすべて取り出す
          if params[:show_deleted]
            filter = params.slice(:query, :match)
            filter[:primary] = true if params[:primary_only]
            filter[:prohibited] = false if params[:hide_prohibited]
            all_items |= @group_repository.filter(**filter).map(:name)
          end

          all_items.sort!
          all_items.reverse! if params[:order] == "name.desc"

          pager = Yuzakan::Utils::Pager.new(all_items,
                                            **params.slice(:page,
                                              :per_page)) do |link_params|
            routes.path(:groups, **params.to_h, **link_params)
          end

          groups = get_groups(pager.page_items).map do |group|
            # プロバイダーから削除しされているが、レポジトリ―では残っている場合は同期する。
            group = get_sync_group(group.name) if !group.deleted && !groups_services.key?(group.name)
            {
              **convert_for_json(group),
              services: groups_services[group.name] || [],
            }
          end

          {
            groups: groups,
            headers: pager.headers,
          }
        end

        private def get_sync_group(groupname)
          @sync_group ||= SyncGroup.new(
            service_repository: @service_repository, group_repository: @group_repository)
          result = @sync_group.call({groupname: groupname})
          if result.failure?
            logger.error "[#{self.class.name}] Failed sync group: #{groupname} - #{result.errors}"
            halt_json 500, errors: result.errors
          end
          result.group
        end

      end
    end
  end
end
