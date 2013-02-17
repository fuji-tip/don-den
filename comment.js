$(document).ready(function(){
  $("form#commentform").submit(function() { // loginForm is submitted
    var comment = $("*[name=comment]").val(); // get username
    var asin = $("#asin").attr('value');
    //alert('yeah');
    if (comment && asin) { // values are not empty
      $.ajax({
        type: "GET",
        url: "./insert.pl", // URL of the Perl script
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        // send username and password as parameters to the Perl script
        data: "comment=" + comment + "&asin=" + asin,
        // script call was *not* successful
        error: function(XMLHttpRequest, textStatus, errorThrown) {
	  //alert('error1');
          $('div#loginResult').text("responseText: " + XMLHttpRequest.responseText 
            + ", textStatus: " + textStatus 
            + ", errorThrown: " + errorThrown);
          $('div#result').addClass("error");
        }, // error 
        // script call was successful 
        // data contains the JSON values returned by the Perl script 
        success: function(data){
          if (data.error) { // script returned error
	    //alert('error');
            $('div#result').text("data.error: " + data.error);
            $('div#result').addClass("error");
          } // if
          else { // login was successful
	    //alert('success');
            $('*[name=comment]').val("");
            $('div#result').text("data.success: " + data.success);
	    $('div#new_comment').html(comment);
	    $('div#new_comment').attr('class', 'comment');
	    $('div#new_comment').attr('id', '');
	    $('body').append("<div id='new_comment'></div>");
            $('div#result').addClass("success");
          } //else
        } // success
      }); // ajax
    } // if
    else {
      $('div#result').text("enter username and password");
      $('div#result').addClass("error");
    } // else
    $('div#result').fadeIn();
    return false;
  });
});
