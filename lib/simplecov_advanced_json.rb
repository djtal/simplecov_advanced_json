require 'simplecov'
require 'simplecov_advanced_json/version'
require 'json'

module SimplecovAdvancedJson
  class Error < StandardError; end

  module Formatter
    class AdvancedJSONFormatter
      def format(result)
        data = {}
        data[:timestamp] = result.created_at.to_i
        data[:command_name] = result.command_name
        data[:groups] =  {}
        results.groups.each do |name, files|
          data[:groups][name] = {
            covered_percent: files.covered_percent,
            covered_strength: files.covered_strength.nan? ? 0.0 : files.covered_strength,
            covered_lines: files.covered_lines,
            total_lines: files.total_lines
          }
        end
        data[:metrics] = {
          covered_percent: result.covered_percent,
          covered_strength: result.covered_strength.nan? ? 0.0 : result.covered_strength,
          covered_lines: result.covered_lines,
          total_lines: result.total_lines
        }

        json = data.to_json

        File.open(output_filepath, "w+") do |file|
          file.puts json
        end

        puts output_message(result)

        json
      end

      def output_filename
        'coverage.json'
      end

      def output_filepath
        File.join(output_path, output_filename)
      end

      def output_message(result)
        "Coverage report generated for #{result.command_name} to #{output_filepath}. #{result.covered_lines} / #{result.total_lines} LOC (#{result.covered_percent.round(2)}%) covered."
      end

    private

      def output_path
        SimpleCov.coverage_path
      end

    end
  end
end
