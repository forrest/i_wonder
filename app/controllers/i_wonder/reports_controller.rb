module IWonder
  class ReportsController < ApplicationController
    layout "i_wonder"
    
     def index
        @reports = Report.all
      end
      
      def show
        @report = Report.find(params[:id])
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
    
    
  end
end
