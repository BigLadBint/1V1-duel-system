let names = {}

window.addEventListener('message', e => {
    const d = e.data

    if (d.action === 'invite') {
        document.getElementById('inviteText').innerText =
            `Player ID ${d.from} invited you to a 1v1`
        document.getElementById('invite').classList.remove('hidden')
    }

    if (d.action === 'showHUD') {
        names = d.names
        updateScore(d.score)
        document.getElementById('hud').classList.remove('hidden')
    }

    if (d.action === 'updateScore') updateScore(d.score)
    if (d.action === 'hideHUD') document.getElementById('hud').classList.add('hidden')

    if (d.action === 'countdown') {
        document.getElementById('countdown').innerText = d.text
        document.getElementById('countdown').classList.remove('hidden')
    }

    if (d.action === 'clearCountdown')
        document.getElementById('countdown').classList.add('hidden')
})

function updateScore(score) {
    const ids = Object.keys(score)
    document.getElementById('p1').innerText = `${names[ids[0]]}: ${score[ids[0]]}`
    document.getElementById('p2').innerText = `${names[ids[1]]}: ${score[ids[1]]}`
}

function accept() {
    fetch(`https://${GetParentResourceName()}/accept`, { method: 'POST' })
    document.getElementById('invite').classList.add('hidden')
}

function decline() {
    fetch(`https://${GetParentResourceName()}/decline`, { method: 'POST' })
    document.getElementById('invite').classList.add('hidden')
}
