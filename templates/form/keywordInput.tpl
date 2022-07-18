{**
* Custom template to overwrite the original template /lib/pkp/templates/form/keywordInput.tpl.
* This template uses the lobid API to fetch GND keywords and autosuggest them at step 3
* of the submission process.
*}


{* Assign unique ID to keywords field.*}
{assign var="uniqId" value="-"|concat:$FBV_uniqId|escape}


{* Check if text input is multilingual and has more than 1 locale.*}
{if $FBV_multilingual && count($formLocales) > 1}

    {* Loop over locales and use tagit widget for each locale.*}
    {foreach name=formLocales from=$formLocales key=thisFormLocale item=thisFormLocaleName}

        {* For German keyword input, use keywords fetched from lobid API.*}
        {if $thisFormLocale === "de_DE"}
            <script>
                $(document).ready(function(){ldelim}
                $("#{$thisFormLocale|escape:jqselector}-{$FBV_id}{$uniqId}").tagit({ldelim}
                fieldName: "keywords[{$thisFormLocale|escape}-{$FBV_id|escape}][]",
                allowSpaces: true,
                    {if !$FBV_disabled} // If form button not disabled.
                        tagSource: function(search, showChoices) {ldelim}
                        $.ajax({ldelim}
                        url: "//lobid.org/gnd/search",
                        data: {
                            q: search.term,
                            format: "json:suggest",
                            size: 100,
                        },
                        dataType: "jsonp",
                        success: function(choices) {ldelim}

                        // Iterate over response, and concatenate jsonp information.
                        var resultsArray = [];
                    $.each(choices,function(index,elem){ldelim}
                    var result = elem.label + ' | GND-Link: ' + elem.id;
                    resultsArray.push(result);
                    {rdelim});
                    showChoices(resultsArray);
                    {rdelim}
                    {rdelim});
                    {rdelim}
                {else}
                    availableTags: {$FBV_availableKeywords.$thisFormLocale|@json_encode}
                {/if}
                {rdelim});

                // Tag-it has no "read-only" option, so we must remove input elements to disable the widget.
                {if $FBV_disabled}
                    $("#{$thisFormLocale|escape:jqselector}-{$FBV_id|concat:$uniqId|escape}").find('.tagit-close, .tagit-new').remove();
                {/if}
                {rdelim});
            </script>

            {* For non-German keywords, fetch the available ones that have already been used.*}
        {else}
            <script>
                $(document).ready(function(){ldelim}
                $("#{$thisFormLocale|escape:jqselector}-{$FBV_id}{$uniqId}").tagit({ldelim}
                fieldName: "keywords[{$thisFormLocale|escape}-{$FBV_id|escape}][]",
                {if $thisFormLocale != $formLocale && empty($FBV_currentKeywords.$thisFormLocale)}placeholderText: "{$thisFormLocaleName|escape}",{/if}
                allowSpaces: true,
                    {if $FBV_sourceUrl && !$FBV_disabled}
                        tagSource: function(search, showChoices) {ldelim}
                        $.ajax({ldelim}
                        url: "{$FBV_sourceUrl}&locale={$thisFormLocale|escape}", {* this url should return a JSON array of possible keywords *}
                        data: search,
                        success: function(choices) {ldelim}
                        showChoices(choices);
                    {rdelim}
                    {rdelim});
                    {rdelim}
                {else}
                    availableTags: {$FBV_availableKeywords.$thisFormLocale|@json_encode}
                {/if}
                {rdelim});

                // Tag-it has no "read-only" option, so we must remove input elements to disable the widget.
                {if $FBV_disabled}
                    $("#{$thisFormLocale|escape:jqselector}-{$FBV_id|concat:$uniqId|escape}").find('.tagit-close, .tagit-new').remove();
                {/if}
                {rdelim});
            </script>
        {/if}
    {/foreach}

    {* Popover container for multiple locales*}
    <script>
        $(function() {ldelim}
        $('#{$FBV_id|escape:javascript}-localization-popover-container{$uniqId}').pkpHandler(
        '$.pkp.controllers.form.MultilingualInputHandler'
        );
        {rdelim});
    </script>

    {* Add localization_popover_container_focus_forced class to multilingual tag-it
               fields. This is a workaround to a focus bug which prevents a tag-it
               value from being deleted when it is in a multilingual popover.
               See: https://github.com/pkp/pkp-lib/issues/3003 *}
    <span id="{$FBV_id|escape}-localization-popover-container{$uniqId}"
        class="localization_popover_container localization_popover_container_focus_forced pkpTagit">
        <ul class="localizable {if $formLocale != $currentLocale} flag flag_{$formLocale|escape}{/if}"
            id="{$formLocale|escape}-{$FBV_id|escape}{$uniqId}">
            {if $FBV_currentKeywords}
                {foreach from=$FBV_currentKeywords.$formLocale item=currentKeyword}<li>
                    {$currentKeyword|escape}</li>{/foreach}
            {/if}
        </ul>
        {if $FBV_label_content}<span>{$FBV_label_content}</span>{/if}
        <div class="localization_popover">
            {foreach from=$formLocales key=thisFormLocale item=thisFormLocaleName}
                {if $formLocale != $thisFormLocale}
                    <ul class="multilingual_extra flag flag_{$thisFormLocale|escape}"
                        id="{$thisFormLocale}-{$FBV_id|escape}{$uniqId}">
                        {if $FBV_currentKeywords}
                            {foreach from=$FBV_currentKeywords.$thisFormLocale item=currentKeyword}<li>
                                {$currentKeyword|escape}</li>{/foreach}
                        {/if}
                    </ul>
                {/if}
            {/foreach}
        </div>
    </span>

    {* If this is not a multilingual keyword field or there is only one locale available. *}
{else}
    <script>
        $(document).ready(function(){ldelim}
        $("#{$FBV_id|escape:jqselector}{$uniqId}").tagit({ldelim}
        fieldName: "keywords[{if $FBV_multilingual}{$formLocale|escape}-{/if}{$FBV_id|escape}][]",
        allowSpaces: true,

            // Use lobid API as tag source.
            {if !$FBV_disabled}
                tagSource: function(search, showChoices) {ldelim}
                $.ajax({ldelim}
                url: "//lobid.org/gnd/search",
                data: {
                    q: search.term,
                    format: "json:suggest",
                    size: 100,
                },
                dataType: "jsonp",
                success: function(choices) {ldelim}
                
                // Iterate over response, and concatenate additional jsonp information.
                var resultsArray = [];
            $.each(choices,function(index,elem){ldelim}
            var result = elem.label + ' | GND-Link: ' + elem.id;
            
            resultsArray.push(result);
            {rdelim});
            showChoices(resultsArray);
            {rdelim}
            {rdelim});
            {rdelim}
        {else}
            availableTags: {$FBV_availableKeywords.$formLocale|@json_encode}
        {/if}
        {rdelim});

        // Tag-it has no "read-only" option, so we must remove input elements to disable the widget.
        {if $FBV_disabled}
            $("#{$FBV_id|escape}{$uniqId}").find('.tagit-close, .tagit-new').remove();
            $("#{$FBV_id|escape}{$uniqId}:empty").removeClass('tagit');
        {/if}
        {rdelim});
    </script>

    <!-- The container which will be processed by tag-it.js as the interests widget -->
    <ul id="{$FBV_id|escape}{$uniqId}">
        {if $FBV_currentKeywords}
            {foreach from=$FBV_currentKeywords.$formLocale item=currentKeyword}<li>
                {$currentKeyword|escape}</li>{/foreach}
        {/if}</ul>
    {if $FBV_label_content}<span>{$FBV_label_content}</span>{/if}
{/if}
