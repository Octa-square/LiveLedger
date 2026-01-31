# Sign In Button Not Responding – Debug Checklist

## What was checked in code

- **Auth screen:** LiveLedgerApp uses **SimpleAuthView** (not AuthView) for sign in/up.
- **Log In button** is **disabled** when:
  - `email.isEmpty` **or** `password.isEmpty`
  - When disabled: opacity 0.5 (looks dimmed).
- **Errors:** Shown in red text below the button via `loginError` (wrong password, account locked, etc.).
- **Debug prints added:** Tapping **Log In** or **Continue** (Sign Up) now prints to the Xcode console so you can see if the tap is received and what the result is.

---

## Test #5 first – Sign up with a different email

1. Tap **Sign Up** (top tab).
2. Enter:
   - **Full Name:** Test User  
   - **Email:** testreview@test.com  
   - **Password:** Test123!  
   - **Confirm Password:** Test123!  
   - **Store Name:** (any)  
   - Check **I agree to the Terms**.
3. Tap **Continue**.

**Expected:** Account is created and you move to onboarding/tutorial.

**If this works:** Sign-up flow is OK; the issue is likely with Log In (wrong password, account not found, or button disabled).

**If this fails:** Note any red error text and what the console prints (see below).

---

## 1. Validation / error text

- **Log In:** Button is disabled (dimmed) if **Email** or **Password** is empty.
- **Red text** below the button = `loginError` (e.g. "No account found", "Wrong password", "Account locked").
- Check that both fields are non-empty and that no error message is stuck on screen.

---

## 2. Console output when you tap Log In

After the change, when you tap **Log In** you should see one of:

- **Tap received, success:**  
  `[Auth] Log In tapped – email: your@email.com, password length: 8`  
  `[Auth] Log In success – isAuthenticated: true`

- **Tap received, wrong password / no account:**  
  `[Auth] Log In tapped – ...`  
  `[Auth] Log In error: <message>`

- **Tap received, security questions:**  
  `[Auth] Log In – requires security questions for ...`

- **Tap received, account locked:**  
  `[Auth] Log In – account locked`

**If you see nothing when you tap:** The button is likely **disabled** (email or password empty). Fill both fields and try again.

---

## 3. Is the button disabled?

- **Log In** is disabled when `email.isEmpty || password.isEmpty`.
- When disabled: opacity 0.5 (looks grayed out).
- **Try:** Enter a valid email and a password (e.g. 8+ chars), then tap **Log In** multiple times and watch the console for `[Auth] Log In tapped ...`.

---

## 4. Did the account get created?

- Switch to **Sign Up**.
- Use the **same email** you use for Log In (e.g. applereview@liveledger.com).
- Fill all required fields and tap **Continue**.

**If you see:** “An account with this email already exists. Please sign in instead.”  
→ The account exists; the problem is Log In (password, security questions, or locked).

**If sign-up succeeds** with that email:  
→ You just created/replaced the account; try Log In again with the same password you used for sign-up.

---

## 5. Try sign up fresh (Test #5)

- **Email:** testreview@test.com  
- **Password:** Test123!  
- **Confirm:** Test123!  
- Agree to terms and tap **Continue**.

**Expected:** Sign-up works and you proceed.  
**Console:** You should see `[Auth] Sign Up (Continue) tapped – email: testreview@test.com`.

If **Test #5 works** but Log In still doesn’t respond:

- Confirm you’re on the **Log In** tab (not Sign Up).
- Confirm **email** and **password** are both non-empty (button not dimmed).
- Check console for `[Auth] Log In tapped ...` and the following line (success or error).

Paste the **exact** console output when you tap Log In (and, if useful, when you tap Continue for sign-up) so we can see what path is taken.
