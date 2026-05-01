document.addEventListener('DOMContentLoaded', function () {
  const form = document.getElementById('contactForm');

  if (!form) return;

  form.addEventListener('submit', function (event) {
    event.preventDefault();

    const name = document.getElementById('name').value.trim();
    const email = document.getElementById('email').value.trim();
    const phone = document.getElementById('phone').value.trim();
    const message = document.getElementById('message').value.trim();

    if (!name || !email || !phone || !message) {
      alert('Please fill in all fields before sending your request.');
      return;
    }

    const subject = encodeURIComponent('Company Registration Inquiry from ' + name);
    const body = encodeURIComponent(
      `Name: ${name}%0D%0AEmail: ${email}%0D%0APhone: ${phone}%0D%0A%0D%0AMessage:%0D%0A${message}`
    );
    const mailtoLink = `mailto:registration@swiftregister.example?subject=${subject}&body=${body}`;

    window.location.href = mailtoLink;
  });
});
