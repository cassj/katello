require 'katello_test_helper'

class Actions::Katello::Foreman::ContentUpdateTest < ActiveSupport::TestCase
  include Dynflow::Testing
  include Support::Actions::RemoteAction

  let(:action_class) { ::Actions::Katello::Foreman::ContentUpdate }
  let(:action) { create_action action_class }

  let(:environment) do
    katello_environments(:library)
  end

  let(:content_view) do
    katello_content_views(:library_view)
  end

  before do
    stub_remote_user(true)
  end

  it 'plans' do
    plan_action(action, environment, content_view)
    assert_finalize_phase(action)
    action.input.must_equal("environment_id" => environment.id,
                            "content_view_id" => content_view.id,
                            "remote_user" => Katello.config.pulp.default_login,
                            "remote_cp_user" => Katello.config.pulp.default_login)
  end

  it 'updates the foreman content' do
    ::Katello::Foreman.expects(:update_puppet_environment).with do |view, env|
      env.id.must_equal environment.id
      view.id.must_equal content_view.id
    end
    plan_action(action, environment, content_view)
    finalize_action(action)
  end
end
