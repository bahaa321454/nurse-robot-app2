// Initial Sample Data
const initialPatients = [
  {
    id: "p1",
    name: "أحمد محمود إبراهيم",
    room: "غرفة 104 - سرير أ",
    diagnosis: "متابعة ما بعد جراحة المرارة",
    dischargeDate: "2026-11-22",
    dischargeTime: "12:00",
    medications: [
      {
        id: "m1",
        name: "Augmentin 1g",
        type: "أقراص",
        dosage: "قرص واحد بعد الغداء",
        time: "14:00",
        notes: "يجب تناوله مع كوب ماء كامل بعد الأكل مباشرة",
        image: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400",
        taken: false
      },
      {
        id: "m2",
        name: "Panadol Extra",
        type: "أقراص",
        dosage: "قرصين عند اللزوم",
        time: "20:00",
        notes: "مسكن للآلام والصداع",
        image: "https://images.unsplash.com/photo-1550572017-ed240562e5b7?w=400",
        taken: true
      }
    ]
  },
  {
    id: "p2",
    name: "فاطمة حسن علي",
    room: "غرفة 208 - سرير ب",
    diagnosis: "انتظام ضغط الدم والسكر",
    dischargeDate: "2026-11-25",
    dischargeTime: "10:00",
    medications: [
      {
        id: "m3",
        name: "Concor 5mg",
        type: "أقراص",
        dosage: "قرص واحد صباحاً على الريق",
        time: "09:00",
        notes: "لتنظيم ضربات القلب وضغط الدم",
        image: "https://images.unsplash.com/photo-1587854692152-cbe660dbde88?w=400",
        taken: false
      }
    ]
  }
];

// Load from LocalStorage or initialize
let patients = JSON.parse(localStorage.getItem('nurse_robot_patients')) || initialPatients;
let currentView = 'nurse'; // 'nurse' or 'robot'
let selectedPatientId = patients[0]?.id || null;
let servoOpen = false;

// Audio Synthesizer for Arduino Buzzer simulation
function playAudioTone(freq, duration) {
  try {
    const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.type = 'square';
    osc.frequency.value = freq;
    osc.connect(gain);
    gain.connect(audioCtx.destination);
    osc.start();
    gain.gain.exponentialRampToValueAtTime(0.0001, audioCtx.currentTime + duration);
    osc.stop(audioCtx.currentTime + duration);
  } catch (e) {
    console.log('Audio error:', e);
  }
}

function triggerBuzzer() {
  playAudioTone(1000, 0.2);
  setTimeout(() => playAudioTone(1400, 0.2), 250);
  setTimeout(() => playAudioTone(1800, 0.3), 500);
}

function toggleServo() {
  servoOpen = !servoOpen;
  const badge = document.getElementById('servoState');
  if (servoOpen) {
    badge.innerText = 'الدرج: مفتوح (90°)';
    badge.style.backgroundColor = '#10b981';
    playAudioTone(1600, 0.1);
  } else {
    badge.innerText = 'الدرج: مغلق (0°)';
    badge.style.backgroundColor = '#334155';
    playAudioTone(800, 0.1);
  }
}

// Switch between views
document.getElementById('toggleModeBtn').addEventListener('click', () => {
  if (currentView === 'nurse') {
    currentView = 'robot';
    document.getElementById('nurseView').classList.remove('active');
    document.getElementById('robotView').classList.add('active');
    document.getElementById('currentModeLabel').innerText = 'لوحة تحكم التمريض';
    renderKioskView();
  } else {
    currentView = 'nurse';
    document.getElementById('robotView').classList.remove('active');
    document.getElementById('nurseView').classList.add('active');
    document.getElementById('currentModeLabel').innerText = 'شاشة تابلت الروبوت';
    renderNurseView();
  }
});

function saveToStorage() {
  localStorage.setItem('nurse_robot_patients', JSON.stringify(patients));
}

// Render Nurse Dashboard
function renderNurseView() {
  const container = document.getElementById('patientList');
  container.innerHTML = '';

  patients.forEach(p => {
    const card = document.createElement('div');
    card.className = 'patient-card';
    card.innerHTML = `
      <div class="patient-card-header">
        <div class="patient-name">${p.name}</div>
        <div class="room-badge">${p.room}</div>
      </div>
      <div class="patient-meta">
        <div><strong>ميعاد الخروج:</strong> ${p.dischargeDate} (${p.dischargeTime})</div>
        <div><strong>التشخيص:</strong> ${p.diagnosis || 'لا توجد ملاحظات'}</div>
      </div>
      <div class="meds-list">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
          <strong>جدول الأدوية (${p.medications.length})</strong>
          <button class="btn-sm btn-primary" onclick="openAddMedModal('${p.id}')">➕ دواء</button>
        </div>
        ${p.medications.length === 0 ? '<p style="color:#94a3b8; font-size:12px;">لا يوجد أدوية مسجلة</p>' : ''}
        ${p.medications.map(m => `
          <div class="med-item">
            <div>
              <strong>${m.name}</strong> (${m.type}) - ${m.time}
              <div style="font-size:11px; color:#64748b;">${m.dosage}</div>
            </div>
            <div>
              <span class="${m.taken ? 'med-taken' : 'med-pending'}">${m.taken ? '✔ تم الأخذ' : '⏳ انتظار'}</span>
              <button class="btn-sm" onclick="toggleMedStatus('${p.id}', '${m.id}')">تبديل</button>
            </div>
          </div>
        `).join('')}
      </div>
      <div style="margin-top:12px; display:flex; justify-content:space-between;">
        <button class="btn-sm btn-warning" onclick="selectForKiosk('${p.id}')">عرض على شاشة الروبوت</button>
        <button class="btn-sm btn-danger" onclick="deletePatient('${p.id}')">حذف</button>
      </div>
    `;
    container.appendChild(card);
  });
}

function selectForKiosk(id) {
  selectedPatientId = id;
  document.getElementById('toggleModeBtn').click();
}

// Render Kiosk Display (Robot Tablet)
function renderKioskView() {
  const select = document.getElementById('kioskPatientSelect');
  select.innerHTML = patients.map(p => `
    <option value="${p.id}" ${p.id === selectedPatientId ? 'selected' : ''}>${p.name} (${p.room})</option>
  `).join('');

  const patient = patients.find(p => p.id === selectedPatientId) || patients[0];
  if (!patient) return;

  document.getElementById('kioskPatientName').innerText = patient.name;
  document.getElementById('kioskRoom').innerText = patient.room;
  document.getElementById('kioskDischargeDate').innerText = `${patient.dischargeDate} - ${patient.dischargeTime}`;
  document.getElementById('kioskDiagnosis').innerText = patient.diagnosis || 'متابعة روتينية';

  // Find next pending medication
  const pendingMed = patient.medications.find(m => !m.taken) || patient.medications[0];
  if (pendingMed) {
    document.getElementById('kioskMedTime').innerText = pendingMed.time;
    document.getElementById('kioskMedType').innerText = pendingMed.type;
    document.getElementById('kioskMedName').innerText = pendingMed.name;
    document.getElementById('kioskMedDosage').innerText = pendingMed.dosage;
    document.getElementById('kioskMedNotes').innerText = pendingMed.notes || 'تناول الجرعة حسب التعليمات المحددة';
    if (pendingMed.image) {
      document.getElementById('kioskMedImg').src = pendingMed.image;
    }
    const btn = document.getElementById('takeMedBtn');
    if (pendingMed.taken) {
      btn.innerText = '✅ تم أخذ هذا الدواء مسبقاً';
      btn.style.backgroundColor = '#64748b';
    } else {
      btn.innerText = '✅ أخذت الدواء الآن (تأكيد تناول الجرعة)';
      btn.style.backgroundColor = '#10b981';
    }
  }
}

function changeKioskPatient(id) {
  selectedPatientId = id;
  renderKioskView();
}

function confirmMedTaken() {
  const patient = patients.find(p => p.id === selectedPatientId);
  if (!patient) return;
  const pendingMed = patient.medications.find(m => !m.taken);
  if (pendingMed) {
    pendingMed.taken = true;
    saveToStorage();
    playAudioTone(2000, 0.2);
    // close dispenser automatically
    if (servoOpen) toggleServo();
    alert('شفاك الله وعافاك! تم تسجيل أخذ الجرعة وتحديث لوحة التمريض.');
    renderKioskView();
  }
}

function toggleMedStatus(patientId, medId) {
  const p = patients.find(x => x.id === patientId);
  if (!p) return;
  const m = p.medications.find(x => x.id === medId);
  if (m) {
    m.taken = !m.taken;
    saveToStorage();
    renderNurseView();
  }
}

// Modal management
function openModal(id) { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }

function savePatient(e) {
  e.preventDefault();
  const newP = {
    id: 'p_' + Date.now(),
    name: document.getElementById('pName').value.trim(),
    room: document.getElementById('pRoom').value.trim(),
    dischargeDate: document.getElementById('pDischargeDate').value,
    dischargeTime: document.getElementById('pDischargeTime').value,
    diagnosis: document.getElementById('pDiagnosis').value.trim(),
    medications: []
  };
  patients.push(newP);
  saveToStorage();
  closeModal('addPatientModal');
  e.target.reset();
  renderNurseView();
}

function deletePatient(id) {
  if (confirm('هل أنت متأكد من حذف هذا المريض؟')) {
    patients = patients.filter(p => p.id !== id);
    saveToStorage();
    renderNurseView();
  }
}

let activePatientForMed = null;
let uploadedImgData = null;

function openAddMedModal(patientId) {
  activePatientForMed = patientId;
  uploadedImgData = null;
  document.getElementById('targetPatientId').value = patientId;
  openModal('addMedModal');
}

function handleMedImage(e) {
  const file = e.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = (event) => {
      uploadedImgData = event.target.result;
    };
    reader.readAsDataURL(file);
  }
}

function saveMedication(e) {
  e.preventDefault();
  const p = patients.find(x => x.id === activePatientForMed);
  if (!p) return;

  const urlInput = document.getElementById('mImageUrl').value.trim();
  const img = uploadedImgData || urlInput || 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400';

  const newMed = {
    id: 'm_' + Date.now(),
    name: document.getElementById('mName').value.trim(),
    type: document.getElementById('mType').value,
    time: document.getElementById('mTime').value,
    dosage: document.getElementById('mDosage').value.trim(),
    notes: document.getElementById('mNotes').value.trim(),
    image: img,
    taken: false
  };

  p.medications.push(newMed);
  saveToStorage();
  closeModal('addMedModal');
  e.target.reset();
  renderNurseView();
}

// Initial render
renderNurseView();
