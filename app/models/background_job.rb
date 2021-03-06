class BackgroundJob < ActiveRecord::Base

  FINISHED = 0
  RUNNING = 1
  FAILED = 2

  def self.create(description, params = {})
    if BackgroundJob.count > OWP.config.tasks.max_records
      limit_record = BackgroundJob.first( :order => "id DESC", :offset => OWP.config.tasks.max_records)
      BackgroundJob.delete_all(["id <= ?", limit_record.id])
    end

    super(:description => description, :status => RUNNING, :params => Marshal.safe_dump(params))
  end

  def finish
    self.status = FINISHED
    save
  end

  def t_description(locale = I18n.locale)
    params = Marshal.safe_load(self.params)
    params[:locale] = locale
    I18n.t("admin.tasks." + self.description, params)
  end

  def self.stop_running
    BackgroundJob.where(:status => RUNNING).update_all(:status => FAILED)
  end

end
