module IWonder
  class AbTestsController < ApplicationController
    layout "i_wonder"

    def index
      @ab_tests = AbTest.all
    end

    def show
      @ab_test = AbTest.find(params[:id])
    end

    def new
      @ab_test = AbTest.new(params[:ab_test])
    end

    def create
      @ab_test = AbTest.new(params[:ab_test])

      if @ab_test.save
        redirect_to @ab_test, :notice => "Successfully created ABTest"
      else
        render "new"
      end
    end

    def edit
      @ab_test = AbTest.find(params[:id])
      render "edit"
    end

    def update
      @ab_test = AbTest.find(params[:id])

      if @ab_test.update_attributes(params[:ab_test])
        redirect_to @ab_test, :notice => "Successfully updated ABTest"
      else
        render "edit"
      end
    end

    def destroy
      @ab_test = AbTest.find(params[:id])
      @ab_test.destroy
      redirect_to ab_tests_path, :notice => "ABTest has been destroyed"
    end
  end
end
