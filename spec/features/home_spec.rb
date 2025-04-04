# frozen_string_literal: true

RSpec.feature "Home", :db do
  init_feature_spec

  scenario "visiting the home page shows a login screen" do
    visit "/"

    expect(page).to have_content "ログイン"
  end
end
