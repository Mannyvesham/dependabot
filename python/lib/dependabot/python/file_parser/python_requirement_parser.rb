# typed: strict
# frozen_string_literal: true

require "toml-rb"
require "open3"
require "dependabot/errors"
require "dependabot/shared_helpers"
require "dependabot/python/file_parser"
require "dependabot/python/pip_compile_file_matcher"
require "dependabot/python/requirement"

module Dependabot
  module Python
    class FileParser
      class PythonRequirementParser
        extend T::Sig

        sig { returns(T::Array[Dependabot::DependencyFile]) }
        attr_reader :dependency_files

        sig { params(dependency_files: T::Array[Dependabot::DependencyFile]).void }
        def initialize(dependency_files:)
          @dependency_files = dependency_files
        end

        sig { returns(T.untyped) }
        def user_specified_requirements
          [
            pipfile_python_requirement,
            pyproject_python_requirement,
            pip_compile_python_requirement,
            python_version_file_version,
            runtime_file_python_version,
            setup_file_requirement
          ].compact
        end

        # TODO: Add better Python version detection using dependency versions
        # (e.g., Django 2.x implies Python 3)
        sig { returns(T.untyped) }
        def imputed_requirements
          requirement_files.flat_map do |file|
            T.must(file.content).lines
             .select { |l| l.include?(";") && l.include?("python") }
             .filter_map { |l| l.match(/python_version(?<req>.*?["'].*?['"])/) }
             .map { |re| T.must(re.named_captures.fetch("req")).gsub(/['"]/, "") }
             .select { |r| valid_requirement?(r) }
          end
        end

        private

        # Parses the Pipfile content to extract the Python version requirement.
        #
        # @return [String, nil] the Python version requirement if specified in the Pipfile,
        #   or nil if the requirement is not present or does not start with a digit.
        sig { returns(T.nilable(String)) }
        def pipfile_python_requirement
          return unless pipfile

          parsed_pipfile = TomlRB.parse(T.must(pipfile).content)
          requirement =
            parsed_pipfile.dig("requires", "python_full_version") ||
            parsed_pipfile.dig("requires", "python_version")
          return unless requirement&.match?(/^\d/)

          requirement
        end

        sig { returns(T.nilable(String)) }
        def pyproject_python_requirement
          return unless pyproject

          pyproject_object = TomlRB.parse(T.must(pyproject).content)

          # Check for PEP621 requires-python
          pep621_python = pyproject_object.dig("project", "requires-python")
          return pep621_python if pep621_python

          # Fallback to Poetry configuration
          poetry_object = pyproject_object.dig("tool", "poetry")

          poetry_object&.dig("dependencies", "python") ||
            poetry_object&.dig("dev-dependencies", "python")
        end

        sig { returns(T.nilable(String)) }
        def pip_compile_python_requirement
          requirement_files.each do |file|
            next unless T.must(pip_compile_file_matcher).lockfile_for_pip_compile_file?(file)

            marker = /^# This file is autogenerated by pip-compile with [pP]ython (?<version>\d+.\d+)$/m
            match = marker.match(file.content)
            next unless match

            return match[:version]
          end

          nil
        end

        sig { returns(T.nilable(String)) }
        def python_version_file_version
          return unless python_version_file

          # read the content, split into lines and remove any lines with '#'
          content_lines = T.must(T.must(python_version_file).content).each_line.map do |line|
            line.sub(/#.*$/, " ").strip
          end.reject(&:empty?)

          file_version = content_lines.first
          return if file_version&.empty?
          return unless T.must(pyenv_versions).include?("#{file_version}\n")

          file_version
        end

        sig { returns(T.nilable(String)) }
        def runtime_file_python_version
          return unless runtime_file

          file_version = T.must(T.must(runtime_file).content)
                          .match(/(?<=python-).*/)&.to_s&.strip
          return if file_version&.empty?
          return unless T.must(pyenv_versions).include?("#{file_version}\n")

          file_version
        end

        sig { returns(T.untyped) }
        def setup_file_requirement
          return unless setup_file

          req = T.must(T.must(setup_file).content)
                 .match(/python_requires\s*=\s*['"](?<req>[^'"]+)['"]/)
                 &.named_captures&.fetch("req")&.strip

          requirement_class.new(req)
          req
        rescue Gem::Requirement::BadRequirementError
          nil
        end

        sig { returns(T.nilable(String)) }
        def pyenv_versions
          @pyenv_versions = T.let(run_command("pyenv install --list"), T.nilable(String))
        end

        sig { params(command: String, env: T::Hash[String, String]).returns(String) }
        def run_command(command, env: {})
          SharedHelpers.run_shell_command(command, env: env, stderr_to_stdout: true)
        end

        sig { returns(T.nilable(PipCompileFileMatcher)) }
        def pip_compile_file_matcher
          @pip_compile_file_matcher = T.let(PipCompileFileMatcher.new(pip_compile_files),
                                            T.nilable(PipCompileFileMatcher))
        end

        sig { returns(T.class_of(Dependabot::Python::Requirement)) }
        def requirement_class
          Dependabot::Python::Requirement
        end

        sig { params(req_string: T.untyped).returns(T::Boolean) }
        def valid_requirement?(req_string)
          requirement_class.new(req_string)
          true
        rescue Gem::Requirement::BadRequirementError
          false
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def pipfile
          dependency_files.find { |f| f.name == "Pipfile" }
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def pipfile_lock
          dependency_files.find { |f| f.name == "Pipfile.lock" }
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def pyproject
          dependency_files.find { |f| f.name == "pyproject.toml" }
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def setup_file
          dependency_files.find { |f| f.name == "setup.py" }
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def python_version_file
          dependency_files.find { |f| f.name == ".python-version" }
        end

        sig { returns(T.nilable(Dependabot::DependencyFile)) }
        def runtime_file
          dependency_files.find { |f| f.name.end_with?("runtime.txt") }
        end

        sig { returns(T::Array[Dependabot::DependencyFile]) }
        def requirement_files
          dependency_files.select { |f| f.name.end_with?(".txt") }
        end

        sig { returns(T.untyped) }
        def pip_compile_files
          dependency_files.select { |f| f.name.end_with?(".in") }
        end
      end
    end
  end
end
