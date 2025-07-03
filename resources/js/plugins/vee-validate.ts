import { defineRule, configure } from 'vee-validate'
import { localize } from '@vee-validate/i18n'
import { all } from '@vee-validate/rules'

Object.entries(all).forEach(([name, rule]) => {
    defineRule(name, rule);
});


configure({
    generateMessage: localize({
        en: {
        messages: {
                required: '{field} is required.',
                numeric: '{field} must only consist of numbers.',
                length: '{field} must be exactly {length} characters.',
                between: '{field} must be between 0:{min}, 1:{max} characters.',
                min: '{field} must be at least {length} characters.',
                max: '{field} must not exceed {length} characters.',
                min_value: '{field} should not be less than {min}',
                max_value: '{field} should not be greater than {max}.',
                confirmed: '{field} must match {target}.',
                email: '{field} must be a valid email.',
                required_if: '{field} is required.'
            },
        },
    }),
})
