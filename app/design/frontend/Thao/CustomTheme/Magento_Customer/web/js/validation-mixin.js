define([
    'jquery',
    'mage/translate'
], function ($, $t) {
    "use strict";

    return function (targetModule) {
        $.validator.addMethod(
            'validate-taxvat-vn',

            function (value) {
                // Allow empty value (field is optional)
                if (!value) {
                    return true;
                }
                // Business Tax ID: Exactly 10 digits
                var tin10 = /^[0-9]{10}$/;

                // Branch Tax ID: 10 digits + hyphen + 3 digits
                var tin13 = /^[0-9]{10}-[0-9]{3}$/;

                return tin10.test(value) || tin13.test(value);
            },
            $t('Tax Identification Number must be either 10 digits or 13 digits (XXX-XXX).')
        );

        return targetModule;
    };
});
