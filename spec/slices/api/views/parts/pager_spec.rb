# frozen_string_literal: true

RSpec.describe API::Views::Parts::Pager do
  init_part_spec
  let_pager

  let(:value) { pager }

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
      currentPage: value.current_page,
      perPage: value.per_page,
      totalPages: value.total_pages,
      total: value.total,
      firstInPage: value.first_in_page,
      lastInPage: value.last_in_page,
    })
  end
end
