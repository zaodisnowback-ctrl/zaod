const timeLabel = document.getElementById('timeLabel');

function updateClock() {
  const now = new Date();
  const time = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  timeLabel.textContent = time;
}

updateClock();
setInterval(updateClock, 30000);

const appButtons = document.querySelectorAll('[data-app]');
const windows = document.querySelectorAll('[data-window]');

function openApp(name) {
  windows.forEach((windowEl) => {
    const isTarget = windowEl.dataset.window === name;
    windowEl.classList.toggle('active', isTarget);
  });

  appButtons.forEach((button) => {
    const isActive = button.dataset.app === name;
    button.classList.toggle('active', isActive);
  });
}

appButtons.forEach((button) => {
  button.addEventListener('click', () => {
    const appName = button.dataset.app;
    if (appName) {
      openApp(appName);
    }
  });
});

document.querySelectorAll('[data-close]').forEach((closeBtn) => {
  closeBtn.addEventListener('click', () => {
    const target = closeBtn.dataset.close;
    const targetWindow = document.getElementById(`window-${target}`);
    if (targetWindow) {
      targetWindow.classList.remove('active');
    }
  });
});
