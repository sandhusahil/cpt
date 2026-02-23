<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Modern Weather App</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap" rel="stylesheet">

<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}

body {
    min-height: 100vh;
    background: linear-gradient(135deg, #1e3c72, #2a5298);
    color: white;
    transition: background 0.6s ease;
}

.app {
    min-height: 100vh;
    padding: 40px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
}

.top-bar {
    display: flex;
    justify-content: center;
    position: relative;
}

.search-box {
    width: 400px;
    position: relative;
}

.search-box input {
    width: 100%;
    padding: 14px 20px;
    border-radius: 50px;
    border: none;
    outline: none;
    font-size: 16px;
}

.suggestions {
    position: absolute;
    top: 55px;
    width: 100%;
    background: white;
    color: black;
    border-radius: 12px;
    max-height: 200px;
    overflow-y: auto;
}

.suggestion-item {
    padding: 10px;
    cursor: pointer;
}

.suggestion-item:hover {
    background: #f0f0f0;
}

.main-weather {
    text-align: center;
    margin-top: 60px;
}

.city {
    font-size: 32px;
    font-weight: 500;
}

.temperature {
    font-size: 120px;
    font-weight: 700;
    margin: 20px 0;
}

.details {
    display: flex;
    justify-content: center;
    gap: 40px;
    font-size: 18px;
    opacity: 0.9;
}

.forecast {
    margin-top: 60px;
    display: flex;
    justify-content: center;
    gap: 20px;
    flex-wrap: wrap;
}

.forecast-day {
    backdrop-filter: blur(15px);
    background: rgba(255,255,255,0.15);
    padding: 20px;
    border-radius: 20px;
    width: 120px;
    text-align: center;
    transition: transform 0.3s ease;
}

.forecast-day:hover {
    transform: translateY(-5px);
}

@media(max-width:600px){
    .temperature {
        font-size: 80px;
    }
    .details {
        flex-direction: column;
        gap: 10px;
    }
    .search-box {
        width: 100%;
    }
}
</style>
</head>

<body>

<div class="app">

    <div class="top-bar">
        <div class="search-box">
            <input type="text" id="cityInput" placeholder="Search city..." autocomplete="off">
            <div id="suggestions" class="suggestions"></div>
        </div>
    </div>

    <div class="main-weather">
        <div class="city" id="cityName">Search a city</div>
        <div class="temperature" id="temperature">--°</div>

        <div class="details">
            <div id="wind">Wind: --</div>
            <div id="time">Time: --</div>
        </div>
    </div>

    <div class="forecast" id="forecast"></div>

</div>

<script>
const cityInput = document.getElementById("cityInput");
const suggestionsBox = document.getElementById("suggestions");

let debounceTimer;

cityInput.addEventListener("input", function () {
    clearTimeout(debounceTimer);
    const query = this.value.trim();

    if (query.length < 2) {
        suggestionsBox.innerHTML = "";
        return;
    }

    debounceTimer = setTimeout(async () => {
        const response = await fetch(
            `https://geocoding-api.open-meteo.com/v1/search?name=${query}&count=5`
        );
        const data = await response.json();

        suggestionsBox.innerHTML = "";

        if (data.results) {
            data.results.forEach(city => {
                const div = document.createElement("div");
                div.classList.add("suggestion-item");
                div.textContent = `${city.name}, ${city.country}`;
                div.onclick = () => {
                    cityInput.value = city.name;
                    suggestionsBox.innerHTML = "";
                    fetchWeather(city.latitude, city.longitude, city.name, city.country);
                };
                suggestionsBox.appendChild(div);
            });
        }
    }, 400);
});

async function fetchWeather(lat, lon, name, country) {

    const response = await fetch(
        `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current_weather=true&daily=temperature_2m_max,temperature_2m_min&timezone=auto`
    );

    const data = await response.json();
    const current = data.current_weather;
    const daily = data.daily;

    document.getElementById("cityName").innerText = `${name}, ${country}`;
    document.getElementById("temperature").innerText = `${current.temperature}°`;
    document.getElementById("wind").innerText = `Wind: ${current.windspeed} km/h`;
    document.getElementById("time").innerText = `Time: ${current.time}`;

    const forecastContainer = document.getElementById("forecast");
    forecastContainer.innerHTML = "";

    daily.time.slice(0,6).forEach((date, index) => {
        forecastContainer.innerHTML += `
            <div class="forecast-day">
                <div>${date.slice(5)}</div>
                <div>⬆ ${daily.temperature_2m_max[index]}°</div>
                <div>⬇ ${daily.temperature_2m_min[index]}°</div>
            </div>
        `;
    });

    changeBackground(current.temperature);
}

function changeBackground(temp) {
    const body = document.body;

    if (temp > 30) {
        body.style.background = "linear-gradient(135deg, #ff512f, #dd2476)";
    } else if (temp > 20) {
        body.style.background = "linear-gradient(135deg, #1e3c72, #2a5298)";
    } else {
        body.style.background = "linear-gradient(135deg, #141e30, #243b55)";
    }
}

document.addEventListener("click", function (e) {
    if (!e.target.closest(".search-box")) {
        suggestionsBox.innerHTML = "";
    }
});
</script>

</body>
</html>
