# frozen_string_literal: true

RSpec.describe API::Views::Parts::Pager do
  init_part_spec

  let(:value) {
    instance_double(ROM::SQL::Plugin::Pagination::Pager).tap do |pager|
      allow(pager).to receive_messages(current_page: 2, per_page: 20,
        total_pages: 5, total: 100, first_in_page: 21, last_in_page: 40)
    end
  }

  it "to_h" do
    data = subject.to_h
    expect(data).to eq({
      current_page: value.current_page,
      per_page: value.per_page,
      total_pages: value.total_pages,
      total: value.total,
      first_in_page: value.first_in_page,
      last_in_page: value.last_in_page,
    })
  end

  it "to_json" do
    json = subject.to_json
    data = JSON.parse(json)
    expect(data).to eq({
      "currentPage" => value.current_page,
      "perPage" => value.per_page,
      "totalPages" => value.total_pages,
      "total" => value.total,
      "firstInPage" => value.first_in_page,
      "lastInPage" => value.last_in_page,
    })
  end
end
