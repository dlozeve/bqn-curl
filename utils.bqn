⟨Hex2Num,RandID⟩⇐

# Parse hexadecimal number
Hex2Num←{16⊸×⊸+˜´⌽(∾"0A"+⟜↕¨10‿6)⊐𝕩}

# random alphanumeric ID of 𝕩 characters
RandId←{(𝕩•rand.Range 62)⊏∾"0aA"+¨↕¨10‿26‿26}
