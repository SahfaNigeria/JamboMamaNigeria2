module.exports = {
    root: true,
    env: {
        es6: true,
        node: true,
    },
    extends: ["eslint:recommended", "google"],
    rules: {
        "quotes": ["error", "double"],
        "indent": ["error", 4],
        "object-curly-spacing": ["error", "never"],
        "max-len": ["error", {code: 120}],
    },
    parserOptions: {
        ecmaVersion: 2018,
    },
};
