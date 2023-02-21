# frozen_string_literal: true

class UserRepository < Hanami::Repository
  associations do
    has_many :members
    has_many :groups, through: :members
  end

  def ordered_all
    users.order(:name).to_a
  end

  def ordered_filter(order: {name: :asc}, filter: {})
    order = {name: :asc} if order.nil? || order.empty?

    order_attributes = order.map do |key, value|
      case value.downcase.intern
      when :asc
        users[key].qualified.asc
      when :desc
        users[key].qualified.desc
      end
    end.compact

    filter(**filter).order(*order_attributes)
  end

  def filter(query: nil, match: :partial, prohibited: nil, deleted: nil)
    q = search(query: query, match: match)
    q = q.where(prohibited: prohibited) unless prohibited.nil?
    case deleted
    when true, false
      q = q.where(deleted: deleted)
    when Range
      q = q.where(deleted: true).where(deleted_at: deleted)
    end
    q
  end

  def search(query: nil, match: :partial)
    return users if query.nil? || query.empty?

    sql_query =
      case match
      when :extract
        query
      when :forward
        "#{query}%"
      when :backward
        "%#{query}"
      when :partial
        "%#{query}%"
      end
    users.where { name.ilike(sql_query) | display_name.ilike(sql_query) }
  end

  private def by_name(name)
    users.where(name: name)
  end

  def all_by_name(name)
    by_name(name).to_a
  end

  def find_by_name(name)
    by_name(name).one
  end

  def find_with_groups(id)
    aggregate(members: :group).where(id: id).map_to(User).one
  end

  def find_with_groups_by_name(name)
    aggregate(members: :group).where(name: name).map_to(User).one
  end

  def set_primary_group(user, group)
    #  既存のプライマリーグループを確認し、設定済みならメンバーを返す
    primary_member = primary_member_for(user)
    return primary_member if primary_member&.group_id == group&.id

    # 既存のプライマリーグループを格下げ
    assoc(:members, user).update(primary_member.id, primary: false) if primary_member

    # プライマリーグループがない場合はそのまま終了
    return if group.nil?

    member = assoc(:members, user).where(group_id: group.id).to_a.first
    if member
      assoc(:members, user).update(member.id, primary: true)
    else
      assoc(:members, user).add(group_id: group.id, primary: true)
    end
  end

  def add_group(user, group)
    member = member_for(user, group)
    return member if member

    assoc(:members, user).add(group_id: group.id)
  end

  def remove_group(user, group)
    member = member_for(user, group)
    return unless member

    assoc(:members, user).remove(member.id)
  end

  private def primary_member_for(user)
    assoc(:members, user).where(primary: true).to_a.first
  end

  private def member_for(user, group)
    assoc(:members, user).where(group_id: group.id).to_a.first
  end

  def clear_group(user)
    assoc(:members, user).delete
  end
end
