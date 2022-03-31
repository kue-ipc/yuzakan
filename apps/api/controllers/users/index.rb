module Api
  module Controllers
    module Users
      class Index
        include Api::Action

        def initialize(user_repository: UserRepository.new,
                       provider_repository: ProviderRepository.new,
                       **opts)
          super
          @user_repository ||= user_repository
          @provider_repository ||= provider_repository
        end

        def call(params)
          query = params[:query]
          query = nil if query&.empty?
          page = params[:page].to_i
          per_page = if Hanami.env == 'production' then 100 else 10 end

          @providers = @provider_repository.ordered_all_with_adapter_by_operation(:read)

          all_list =
            if query
              query = "*#{query}*"
              @providers.flat_map { |provider| provider.search(query) }.uniq.sort
            else
              @providers.flat_map { |provider| provider.list }.uniq.sort
            end
          @total_count = all_list.size
          page_list = all_list[(page * per_page), per_page]
          users_data = @user_repository.by_name(page_list).to_a.to_h { |user| [user.name, user] }
          @users = page_list.map do |name|
            users_data[name] || create_user(name)
          end

          self.status = 200
          headers['Total-Count'] = @total_count.to_s
          self.body = generate_json(@users)
        end

        private def create_user(name)
          userdata = nil
          @providers.each do |provider|
            userdata = provider.read(name)
            break if userdata
          end

          name = userdata[:name]
          display_name = userdata[:display_name] || userdata[:name]
          email = userdata[:email]

          @user_repository.create(name: name, display_name: display_name, email: email)
        end
      end
    end
  end
end
