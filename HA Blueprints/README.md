# Home Assistant blueprints

In this Folder I'm collecting my own blueprints around Home Assistnat. Feel free to use and/or modify them on your own responsibility. I'll try to give a short explanation and usage for each of them here.

## [Air Quality indicator]([LinkDestination](https://raw.githubusercontent.com/kage-chan/HomeLab/refs/heads/main/HA%20Blueprints/AirQualityIndicator.yaml))

Ever wanted an easy indicator that shows you (or the kids) when it's time to get in some fresh air? 💨

This is your automation blueprint. This automation will set a light's color according to air quality. Three indicators are used to determine your in-home air quality:
- CO2
- PM2.5
- VOC

All three are intentionally optional, so you can use the indicators you see fit for your home. For each indicator you can set one or multiple sensors. The worst indicator and/or sensor "wins" and determines the light's color. You can select a light to use as "display". Additionally, I'm using the bulb as night light. As night time sensor I'm using a binary sensor that takes two variables as input: "Night start" and "Night end".

Colors, Brightness, Color temperatures and thresholds are all adjustable through Home Assistant's UI.
