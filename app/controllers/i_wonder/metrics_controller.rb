module IWonder
  class MetricsController < ApplicationController
    layout "i_wonder"
    
     def index
        @metrics = Metric.all
      end

      def show
        @metric = Metric.find(params[:id])
      end

      def new
        @metric = Metric.new(params[:i_wonder_metric])
      end

      def create
        @metric = Metric.new(params[:i_wonder_metric])

        if @metric.save
          redirect_to @metric, :notice => "Successfully created metric"
        else
          render "new"
        end
      end

      def edit
        @metric = Metric.find(params[:id])
        render "edit"
      end

      def update
        @metric = Metric.find(params[:id])

        if @metric.update_attributes(params[:i_wonder_metric])
          redirect_to @metric, :notice => "Successfully updated metric"
        else
          render "edit"
        end
      end

      def destroy
        @metric = Metric.find(params[:id])
        @metric.destroy
        redirect_to i_wonder_metrics_path, :notice => "Metric has been destroyed"
      end
    
  end
end
