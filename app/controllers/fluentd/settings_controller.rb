require "fluent/config/v1_parser"

class Fluentd::SettingsController < ApplicationController
  before_action :login_required
  before_action :find_fluentd
  before_action :set_config, only: [:show, :edit, :update]

  def show
    @backup_files = @fluentd.agent.backup_files_in_new_order.first(Settings.histories_count_in_preview).map do |file_path|
      Fluentd::SettingArchive::BackupFile.new(file_path)
    end

    @running_backedup_file = Fluentd::SettingArchive::BackupFile.new(@fluentd.agent.running_config_backup_file)
  end

  def edit
  end

  def  update
    Fluent::Config::V1Parser.parse(params[:config], @fluentd.config_file)
    @fluentd.agent.config_write params[:config]
    @fluentd.agent.restart if @fluentd.agent.running?
    redirect_to daemon_setting_path(@fluentd)
  rescue Fluent::ConfigParseError => e
    @config = params[:config]
    @error = e.message
    render "edit"
  end

  def source_and_output
    # TODO: error handling if config file has invalid syntax
    # @config = Fluentd::Setting::Config.new(@fluentd.config_file)
  end

  private

  def set_config
    @config = @fluentd.agent.config
  end
end
