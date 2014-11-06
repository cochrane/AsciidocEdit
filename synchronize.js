++++
<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>

<script>

function keep_place() {
    
    var position = localStorage.getItem("scroll_position");
    
    $("body").scrollTop(position)
    
};

$(document).ready(function(){
                  
                  $("#b1").click(function(){
                                 
                                 keep_place()
                                 
                                 });
                  
                  });

$(document).ready(function(){
                  
                  $("#b2").click(function(){
                                 
                                 $("#f2").html("foobar")
                                 
                                 });
                  
                  });

$(document).ready(function(){
                  
                  $(window).scroll(function(){
                                   
                                   var scroll_position = $("body").scrollTop();
                                   
                                   localStorage.setItem("scroll_position", scroll_position);   
                                   })
                  });


</script>


++++
