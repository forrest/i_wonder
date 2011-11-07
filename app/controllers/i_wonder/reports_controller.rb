module IWonder
  class ReportsController < ApplicationController
    layout "i_wonder"
    
    if defined?(newrelic_ignore)
      newrelic_ignore
    end
    
    def index
      @reports = Report.all
    end

    def show
      @report = Report.find(params[:id])
      
      @start_time = (params[:start_time] ? Time.zone.parse(params[:start_time]) : Time.zone.now - 1.month)
      @end_time = (params[:end_time] ? Time.zone.parse(params[:end_time]) : Time.zone.now)
      @interval_length = default_interval_length
      
      respond_to {|format|
        format.html { }
        format.js {
          if @report.line?
            render :partial => "line_report.js"
          else
            render :text => "?"
          end
        }
      }
    end

    def new
      @report = Report.new(params[:report])
    end

    def create
      @report = Report.new(params[:report])

      if @report.save
        redirect_to @report, :notice => "Successfully created report"
      else
        render "new"
      end
    end

    def edit
      @report = Report.find(params[:id])
      render "edit"
    end

    def update
      @report = Report.find(params[:id])

      if @report.update_attributes(params[:report])
        redirect_to @report, :notice => "Successfully updated report"
      else
        render "edit"
      end
    end

    def destroy
      @report = Report.find(params[:id])
      @report.destroy
      redirect_to reports_path, :notice => "Report has been destroyed"
    end
    
  protected
    
    def default_interval_length
      length = @end_time - @start_time
      
      if length > 2.months
        interval_length = 1.week
      elsif length > 1.week
        interval_length = 1.days
      else
        interval_length = 1.hours
      end
      
      # can't show a smaller frequency than the snampshots get taken in.
      longest_metric_frequency = @report.metrics.collect(&:frequency).max
      if longest_metric_frequency > interval_length
        interval_length = longest_metric_frequency 
      end
      
      return interval_length
    end
    
  end
end
