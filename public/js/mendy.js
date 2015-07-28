$(function() {
  $.getScript('./js/config.js', function() {

    var preview_html = '';

    $(".chooser").change(function() {
      preview_html = '';
      $.getJSON(service_url, $("#choices").serialize(), function(data) { 
        $.each(data, function(key, value) {
          preview_html += '<p>' + value.name + '<br><img src="' + render_url + value.layout_md5 + '"></p>';
        });
        $("#suggestions").html(preview_html);
      }).fail(function() {
        $("#suggestions").html('<i>No suggestions for selection</i> ');
      });

    });
  });
});
