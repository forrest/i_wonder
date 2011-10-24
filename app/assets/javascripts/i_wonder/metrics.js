// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.


$(function(){
  $("#metric_collection_type").change(function(){
    $(".details_for_option").hide();
    $("."+$(this).val()+"_details").show();
  });
  
  $("#metric_model_counter_takes_snapshots, #metric_custom_takes_snapshots").change(function(){
    if($(this).prop('checked')){
      $(".snapshot_details").show();
    }else{
      $(".snapshot_details").hide();
    }
  });
})
