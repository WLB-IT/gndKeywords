<?php

/**
 * This plugin uses the lobid API to fetch GND keywords 
 * and autosuggests them in the keyword field.
 */

import('lib.pkp.classes.plugins.GenericPlugin');

class GNDKeywordsPlugin extends GenericPlugin {

	/**
	 * Provide a name for this plugin
	 *
	 * The name will appear in the plugins list where editors can
	 * enable and disable plugins.
	 */
	public function getDisplayName() {
		return __('plugins.generic.gndkeywords.title');
	}

	/**
	 * Provide a description for this plugin
	 *
	 * The description will appear in the plugins list where editors can
	 * enable and disable plugins.
	 */
	public function getDescription() {
		return __('plugins.generic.gndkeywords.desc');
	}

	/**
	 * Register the plugin and hook into functions to change.
	 */
	public function register($category, $path, $mainContextId = null) {

		$success = parent::register($category, $path);

		// Only hook into functions if the plugin is registered and enabled.
		if ($success && $this->getEnabled()) {

			// Use hook to overwrite template before it is rendered and displayed in the submission and quicksubmit steps.
			HookRegistry::register('TemplateResource::getFilename', array($this, '_overridePluginTemplates'));

			// Hide native autosuggest and add custom autosuggest.
			HookRegistry::register('Template::Workflow', array($this, 'gndAutosuggest'));
		}

		return $success;
	}

	/**
	 * Add autosuggest script for keywords.
	 * @param $hookName string
	 * @param $params array
	 */
	public function gndAutosuggest($hookName, $params) {

		// Use smarty API.
		$smarty = $params[1];

		// Display template for custom autosuggest in metadata tab.
		return $smarty->display($this->getTemplateResource('/form/fields/gndSubmissionAutosuggest.tpl'));
	}
}
