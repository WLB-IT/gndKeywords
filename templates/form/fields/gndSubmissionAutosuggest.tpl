{**
* This template uses the lobid API to fetch GND keywords and autosuggest them.
*}

<script>
$(document).ready(function () {ldelim}

    // Remove original autosuggest container.
    $('.autosuggest__results-container').remove();

    // Add additional description.
    var description = ": Mit Up/Down navigieren und mit Leertaste + Enter auswählen.";
    document.querySelector(".pkpFormFieldLabel[for='metadata-keywords-control-de_DE").innerText += description;

    // Ajax call to lobid API.
    $('#metadata-keywords-control-de_DE').autocomplete({ldelim}
        source: function (request, response) {ldelim}
            $.ajax({ldelim}
                url: '//lobid.org/gnd/search',
                dataType: 'jsonp',
                data: {ldelim}
                    q: request.term,
                    format: "json:suggest",
                    size: "30",
                {rdelim},

                // When success, store info in array and return.
                success: function (data) {ldelim}

                    // Response.
                    response($.map(data, function (elem) {ldelim}
                        return elem.label + ' | GND-Link: ' + elem.id;
                    {rdelim}));
                {rdelim}
            {rdelim});
        {rdelim},
        minLength: 2,
        autoFocus: true,

        // Select on enter keypress. FIXME: does not work.
        select: function (event, ui) {ldelim}
              $('#metadata-keywords-control-de_DE').focus().trigger({ldelim}
                type: 'keypress',
                which: 13,
                keyCode: 13
            {rdelim});
        {rdelim}
    {rdelim});

{rdelim})
</script>
