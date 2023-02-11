/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  plugins: [
    require('tailwindcss-themer')({
      themes: [
        {
          name: 'classic-light',
          extend: {
            colors: {
              background: 'white',
              contrast: 'rgb(219 234 254)',
              'button-bg': 'rgb(37 99 235)',
              'button-bg-hover': 'rgb(37 99 235)',
              'button-text': 'white',
              link: 'rgb(29 78 216)',
              text: 'black',
            },
          },
        },
        {
          name: 'classic-dark',
          extend: {
            colors: {
              background: 'rgb(17 24 39)',
              contrast: 'rgb(31 41 55)',
              'button-bg': 'rgb(191 219 254)',
              'button-text': 'rgb(17 24 39)',
              link: 'rgb(96 165 250)',
              text: 'rgb(219 234 254)',
            },
          },
        },
        {
          name: 'neubrutalism-light',
          extend: {
            colors: {
            },
          },
        },
      ],
    }),
  ],
  darkMode: 'class',
};
