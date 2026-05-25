document.addEventListener('DOMContentLoaded', function () {
  const navbar = document.getElementById('navbar');
  const hamburger = document.getElementById('hamburger');
  const navLinks = document.getElementById('navLinks');

  // Sticky navbar shadow on scroll
  if (navbar) {
    window.addEventListener('scroll', function () {
      navbar.style.boxShadow = window.scrollY > 10
        ? '0 4px 24px rgba(20,27,38,0.10)'
        : '';
    });
  }

  // Mobile menu toggle
  if (hamburger && navLinks) {
    hamburger.addEventListener('click', function () {
      const open = navLinks.classList.toggle('nav-open');
      hamburger.setAttribute('aria-expanded', open);
    });
  }

  // Contact form
  const form = document.getElementById('contactForm');
  if (!form) return;

  const submitBtn = document.getElementById('submitBtn');
  const btnText = document.getElementById('btnText');
  const btnSpinner = document.getElementById('btnSpinner');
  const formSuccess = document.getElementById('formSuccess');

  function showError(fieldId, message) {
    const errEl = document.getElementById(fieldId + 'Err');
    if (errEl) errEl.textContent = message;
    const field = document.getElementById(fieldId);
    if (field) field.style.borderColor = '#e53e3e';
  }

  function clearErrors() {
    form.querySelectorAll('.err').forEach(function (el) { el.textContent = ''; });
    form.querySelectorAll('input, textarea, select').forEach(function (el) {
      el.style.borderColor = '';
    });
  }

  function validateEmail(value) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
  }

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    clearErrors();

    const firstName = document.getElementById('firstName').value.trim();
    const lastName  = document.getElementById('lastName').value.trim();
    const email     = document.getElementById('email').value.trim();
    const phone     = document.getElementById('phone').value.trim();
    const service   = document.getElementById('service').value;
    const message   = document.getElementById('message').value.trim();
    const consent   = document.getElementById('consent').checked;

    let valid = true;

    if (!firstName) { showError('firstName', 'First name is required.'); valid = false; }
    if (!lastName)  { showError('lastName',  'Last name is required.');  valid = false; }
    if (!email)             { showError('email', 'Email address is required.'); valid = false; }
    else if (!validateEmail(email)) { showError('email', 'Please enter a valid email address.'); valid = false; }
    if (!service)   { showError('service', 'Please select a service.'); valid = false; }
    if (!message)   { showError('message', 'Message is required.');     valid = false; }
    if (!consent)   { showError('consent', 'You must agree to be contacted.'); valid = false; }

    if (!valid) return;

    // Show spinner
    if (btnText)    btnText.textContent = 'Sending…';
    if (btnSpinner) btnSpinner.classList.remove('hidden');
    if (submitBtn)  submitBtn.disabled = true;

    const fullName = firstName + ' ' + lastName;
    const phoneLine = phone ? '\nPhone: ' + phone : '';
    const subject = 'Company Registration Enquiry – ' + service + ' (' + fullName + ')';
    const body =
      'Name: ' + fullName +
      '\nEmail: ' + email +
      phoneLine +
      '\nService: ' + service +
      '\n\nMessage:\n' + message;

    const mailtoLink =
      'mailto:hello@regpro.co.uk' +
      '?subject=' + encodeURIComponent(subject) +
      '&body=' + encodeURIComponent(body);

    // Small delay so the spinner is visible before the mailto redirect
    setTimeout(function () {
      window.location.href = mailtoLink;

      // Show success state after a short pause (mailto opens the email client)
      setTimeout(function () {
        form.classList.add('hidden');
        if (formSuccess) formSuccess.classList.remove('hidden');
      }, 800);
    }, 400);
  });
});
