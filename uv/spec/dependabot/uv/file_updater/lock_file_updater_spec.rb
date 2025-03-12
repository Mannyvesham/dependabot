# typed: false
# frozen_string_literal: true

require "spec_helper"
require "dependabot/dependency"
require "dependabot/dependency_file"
require "dependabot/uv/file_updater/lock_file_updater"
require "dependabot/shared_helpers"

RSpec.describe Dependabot::Uv::FileUpdater::LockFileUpdater do
  let(:updater) do
    described_class.new(
      dependencies: dependencies,
      dependency_files: dependency_files,
      credentials: credentials,
      index_urls: index_urls
    )
  end

  let(:dependencies) { [dependency] }
  let(:credentials) do
    [Dependabot::Credential.new({
      "type" => "git_source",
      "host" => "github.com",
      "username" => "x-access-token",
      "password" => "token"
    })]
  end
  let(:index_urls) { [] }

  let(:dependency) do
    Dependabot::Dependency.new(
      name: "requests",
      version: "2.23.0",
      requirements: [{
        file: "pyproject.toml",
        requirement: "==2.23.0",
        groups: [],
        source: nil
      }],
      previous_requirements: [{
        file: "pyproject.toml",
        requirement: ">=2.31.0",
        groups: [],
        source: nil
      }],
      previous_version: "2.32.3",
      package_manager: "uv"
    )
  end

  let(:pyproject_content) { fixture("pyproject_files", "uv_simple.toml") }
  let(:lockfile_content) { fixture("uv_locks", "simple.lock") }

  let(:pyproject_file) do
    Dependabot::DependencyFile.new(
      name: "pyproject.toml",
      content: pyproject_content
    )
  end

  let(:lockfile) do
    Dependabot::DependencyFile.new(
      name: "uv.lock",
      content: lockfile_content
    )
  end

  let(:dependency_files) { [pyproject_file, lockfile] }

  describe "#updated_dependency_files" do
    subject(:updated_files) { updater.updated_dependency_files }

    before do
      allow(updater).to receive_messages(
        updated_pyproject_content: updated_pyproject_content,
        updated_lockfile_content_for: updated_lockfile_content
      )
    end

    let(:updated_pyproject_content) do
      pyproject_content.sub(
        "requests>=2.31.0",
        "requests==2.23.0"
      )
    end

    let(:updated_lockfile_content) do
      lockfile_content.sub(
        /name = "requests"\nversion = "2\.32\.3"/, # rubocop:disable Style/RedundantRegexpArgument
        'name = "requests"\nversion = "2.23.0"'
      )
    end

    it "returns updated pyproject.toml and lockfile" do
      expect(updated_files.count).to eq(2)

      pyproject = updated_files.find { |f| f.name == "pyproject.toml" }
      expect(pyproject.content).to include("requests==2.23.0")

      lockfile = updated_files.find { |f| f.name == "uv.lock" }
      expect(lockfile.content).to include('name = "requests"')
      expect(lockfile.content).to include('version = "2.23.0"')
    end

    context "when the lockfile doesn't change" do
      let(:updated_lockfile_content) { lockfile_content }

      it "raises an error" do
        expect { updated_files }.to raise_error("Expected lockfile to change!")
      end
    end

    context "with pyproject preparation" do
      before do
        pyproject_preparer = instance_double(Dependabot::Uv::FileUpdater::PyprojectPreparer)

        allow(Dependabot::Uv::FileUpdater::PyprojectPreparer).to receive(:new)
          .and_return(pyproject_preparer)

        allow(pyproject_preparer).to receive(:freeze_top_level_dependencies_except)
          .with(dependencies)
          .and_return("frozen content")

        allow(pyproject_preparer).to receive_messages(
          update_python_requirement: "python requirement updated content",
          sanitize: "sanitized content"
        )

        # Mock the command execution
        allow(updater).to receive(:run_command).and_return(true)
        allow(File).to receive(:read).with("uv.lock").and_return(updated_lockfile_content)
      end

      it "prepares the pyproject file correctly" do
        expect(Dependabot::Uv::FileUpdater::PyprojectPreparer).to receive(:new)
        updated_files
      end
    end
  end
end
