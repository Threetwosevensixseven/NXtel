; SAADouble.asm - FZX font file
; created with FZXEditor

//        org     0

; --------------------------------------------------------------------------------
; header

header:
        defb    16              ; vertical gap between baselines in pixels

tracking:
        defb    0               ; horizontal gap between characters in pixels

lastchar:
        defb    255             ; last defined character (32-255)

; --------------------------------------------------------------------------------
; character table

table:
; defw offset+16384*kern
; defb 16*leading+width-1

        defw    space -$
        defb    16*0+6-1
        defw    exclamation_mark -$
        defb    16*1+6-1
        defw    quotation_mark -$
        defb    16*1+6-1
        defw    number_sign -$
        defb    16*1+6-1
        defw    dollar_sign -$
        defb    16*1+6-1
        defw    percent_sign -$
        defb    16*1+6-1
        defw    ampersand -$
        defb    16*1+6-1
        defw    apostrophe -$
        defb    16*1+6-1
        defw    left_parenthesis -$
        defb    16*1+6-1
        defw    right_parenthesis -$
        defb    16*1+6-1
        defw    asterisk -$
        defb    16*1+6-1
        defw    plus_sign -$
        defb    16*3+6-1
        defw    comma -$
        defb    16*1+6-1
        defw    hyphen_minus -$
        defb    16*6+6-1
        defw    full_stop -$
        defb    16*11+6-1
        defw    solidus -$
        defb    16*1+6-1
        defw    digit_0 -$
        defb    16*1+6-1
        defw    digit_1 -$
        defb    16*1+6-1
        defw    digit_2 -$
        defb    16*1+6-1
        defw    digit_3 -$
        defb    16*1+6-1
        defw    digit_4 -$
        defb    16*1+6-1
        defw    digit_5 -$
        defb    16*1+6-1
        defw    digit_6 -$
        defb    16*1+6-1
        defw    digit_7 -$
        defb    16*1+6-1
        defw    digit_8 -$
        defb    16*1+6-1
        defw    digit_9 -$
        defb    16*1+6-1
        defw    colon -$
        defb    16*1+6-1
        defw    semicolon -$
        defb    16*1+6-1
        defw    less_than_sign -$
        defb    16*1+6-1
        defw    equals_sign -$
        defb    16*4+6-1
        defw    greater_than_sign -$
        defb    16*1+6-1
        defw    question_mark -$
        defb    16*1+6-1
        defw    commercial_at -$
        defb    16*1+6-1
        defw    latin_capital_letter_a -$
        defb    16*1+6-1
        defw    latin_capital_letter_b -$
        defb    16*1+6-1
        defw    latin_capital_letter_c -$
        defb    16*1+6-1
        defw    latin_capital_letter_d -$
        defb    16*1+6-1
        defw    latin_capital_letter_e -$
        defb    16*1+6-1
        defw    latin_capital_letter_f -$
        defb    16*1+6-1
        defw    latin_capital_letter_g -$
        defb    16*1+6-1
        defw    latin_capital_letter_h -$
        defb    16*1+6-1
        defw    latin_capital_letter_i -$
        defb    16*1+6-1
        defw    latin_capital_letter_j -$
        defb    16*1+6-1
        defw    latin_capital_letter_k -$
        defb    16*1+6-1
        defw    latin_capital_letter_l -$
        defb    16*1+6-1
        defw    latin_capital_letter_m -$
        defb    16*1+6-1
        defw    latin_capital_letter_n -$
        defb    16*1+6-1
        defw    latin_capital_letter_o -$
        defb    16*1+6-1
        defw    latin_capital_letter_p -$
        defb    16*1+6-1
        defw    latin_capital_letter_q -$
        defb    16*1+6-1
        defw    latin_capital_letter_r -$
        defb    16*1+6-1
        defw    latin_capital_letter_s -$
        defb    16*1+6-1
        defw    latin_capital_letter_t -$
        defb    16*1+6-1
        defw    latin_capital_letter_u -$
        defb    16*1+6-1
        defw    latin_capital_letter_v -$
        defb    16*1+6-1
        defw    latin_capital_letter_w -$
        defb    16*1+6-1
        defw    latin_capital_letter_x -$
        defb    16*1+6-1
        defw    latin_capital_letter_y -$
        defb    16*1+6-1
        defw    latin_capital_letter_z -$
        defb    16*1+6-1
        defw    left_square_bracket -$
        defb    16*1+6-1
        defw    reverse_solidus -$
        defb    16*1+6-1
        defw    right_square_bracket -$
        defb    16*1+6-1
        defw    circumflex_accent -$
        defb    16*1+6-1
        defw    low_line -$
        defb    16*2+6-1
        defw    grave_accent -$
        defb    16*7+6-1
        defw    latin_small_letter_a -$
        defb    16*5+6-1
        defw    latin_small_letter_b -$
        defb    16*1+6-1
        defw    latin_small_letter_c -$
        defb    16*5+6-1
        defw    latin_small_letter_d -$
        defb    16*1+6-1
        defw    latin_small_letter_e -$
        defb    16*5+6-1
        defw    latin_small_letter_f -$
        defb    16*1+6-1
        defw    latin_small_letter_g -$
        defb    16*5+6-1
        defw    latin_small_letter_h -$
        defb    16*1+6-1
        defw    latin_small_letter_i -$
        defb    16*2+6-1
        defw    latin_small_letter_j -$
        defb    16*2+6-1
        defw    latin_small_letter_k -$
        defb    16*2+6-1
        defw    latin_small_letter_l -$
        defb    16*2+6-1
        defw    latin_small_letter_m -$
        defb    16*5+6-1
        defw    latin_small_letter_n -$
        defb    16*5+6-1
        defw    latin_small_letter_o -$
        defb    16*5+6-1
        defw    latin_small_letter_p -$
        defb    16*5+6-1
        defw    latin_small_letter_q -$
        defb    16*5+6-1
        defw    latin_small_letter_r -$
        defb    16*5+6-1
        defw    latin_small_letter_s -$
        defb    16*5+6-1
        defw    latin_small_letter_t -$
        defb    16*3+6-1
        defw    latin_small_letter_u -$
        defb    16*5+6-1
        defw    latin_small_letter_v -$
        defb    16*5+6-1
        defw    latin_small_letter_w -$
        defb    16*5+6-1
        defw    latin_small_letter_x -$
        defb    16*5+6-1
        defw    latin_small_letter_y -$
        defb    16*5+6-1
        defw    latin_small_letter_z -$
        defb    16*5+6-1
        defw    left_curly_bracket -$
        defb    16*2+6-1
        defw    vertical_line -$
        defb    16*1+6-1
        defw    right_curly_bracket -$
        defb    16*2+6-1
        defw    tilde -$
        defb    16*4+6-1
        defw    delete -$
        defb    16*2+6-1
        defw    character_128 -$
        defb    16*0+6-1
        defw    character_129 -$
        defb    16*0+6-1
        defw    character_130 -$
        defb    16*0+7-1
        defw    character_131 -$
        defb    16*0+6-1
        defw    character_132 -$
        defb    16*5+6-1
        defw    character_133 -$
        defb    16*0+6-1
        defw    character_134 -$
        defb    16*0+6-1
        defw    character_135 -$
        defb    16*0+6-1
        defw    character_136 -$
        defb    16*5+6-1
        defw    character_137 -$
        defb    16*0+6-1
        defw    character_138 -$
        defb    16*0+6-1
        defw    character_139 -$
        defb    16*0+6-1
        defw    character_140 -$
        defb    16*5+6-1
        defw    character_141 -$
        defb    16*0+6-1
        defw    character_142 -$
        defb    16*0+6-1
        defw    character_143 -$
        defb    16*0+6-1
        defw    character_144 -$
        defb    16*11+6-1
        defw    character_145 -$
        defb    16*0+6-1
        defw    character_146 -$
        defb    16*0+6-1
        defw    character_147 -$
        defb    16*0+6-1
        defw    character_148 -$
        defb    16*5+6-1
        defw    character_149 -$
        defb    16*0+6-1
        defw    character_150 -$
        defb    16*0+6-1
        defw    character_151 -$
        defb    16*0+6-1
        defw    character_152 -$
        defb    16*5+6-1
        defw    character_153 -$
        defb    16*0+6-1
        defw    character_154 -$
        defb    16*0+6-1
        defw    character_155 -$
        defb    16*0+6-1
        defw    character_156 -$
        defb    16*5+6-1
        defw    character_157 -$
        defb    16*0+6-1
        defw    character_158 -$
        defb    16*0+6-1
        defw    character_159 -$
        defb    16*0+6-1
        defw    character_160 -$
        defb    16*0+6-1
        defw    character_161 -$
        defb    16*0+6-1
        defw    character_162 -$
        defb    16*0+6-1
        defw    character_163 -$
        defb    16*0+6-1
        defw    character_164 -$
        defb    16*5+6-1
        defw    character_165 -$
        defb    16*0+6-1
        defw    character_166 -$
        defb    16*0+6-1
        defw    character_167 -$
        defb    16*0+6-1
        defw    character_168 -$
        defb    16*5+6-1
        defw    character_169 -$
        defb    16*0+6-1
        defw    character_170 -$
        defb    16*0+6-1
        defw    character_171 -$
        defb    16*0+6-1
        defw    character_172 -$
        defb    16*5+6-1
        defw    character_173 -$
        defb    16*0+6-1
        defw    character_174 -$
        defb    16*0+6-1
        defw    character_175 -$
        defb    16*0+6-1
        defw    character_176 -$
        defb    16*11+6-1
        defw    character_177 -$
        defb    16*0+6-1
        defw    character_178 -$
        defb    16*0+6-1
        defw    character_179 -$
        defb    16*0+6-1
        defw    character_180 -$
        defb    16*5+6-1
        defw    character_181 -$
        defb    16*0+6-1
        defw    character_182 -$
        defb    16*0+6-1
        defw    character_183 -$
        defb    16*0+6-1
        defw    character_184 -$
        defb    16*5+6-1
        defw    character_185 -$
        defb    16*0+6-1
        defw    character_186 -$
        defb    16*0+6-1
        defw    character_187 -$
        defb    16*0+6-1
        defw    character_188 -$
        defb    16*5+6-1
        defw    character_189 -$
        defb    16*0+6-1
        defw    character_190 -$
        defb    16*0+6-1
        defw    character_191 -$
        defb    16*0+6-1
        defw    character_192 -$
        defb    16*11+6-1
        defw    character_193 -$
        defb    16*0+6-1
        defw    character_194 -$
        defb    16*0+6-1
        defw    character_195 -$
        defb    16*0+6-1
        defw    character_196 -$
        defb    16*5+6-1
        defw    character_197 -$
        defb    16*0+6-1
        defw    character_198 -$
        defb    16*0+6-1
        defw    character_199 -$
        defb    16*0+6-1
        defw    character_200 -$
        defb    16*5+6-1
        defw    character_201 -$
        defb    16*0+6-1
        defw    character_202 -$
        defb    16*0+6-1
        defw    character_203 -$
        defb    16*0+6-1
        defw    character_204 -$
        defb    16*5+6-1
        defw    character_205 -$
        defb    16*0+6-1
        defw    character_206 -$
        defb    16*0+6-1
        defw    character_207 -$
        defb    16*0+6-1
        defw    character_208 -$
        defb    16*11+6-1
        defw    character_209 -$
        defb    16*0+6-1
        defw    character_210 -$
        defb    16*0+6-1
        defw    character_211 -$
        defb    16*0+6-1
        defw    character_212 -$
        defb    16*5+6-1
        defw    character_213 -$
        defb    16*0+6-1
        defw    character_214 -$
        defb    16*0+6-1
        defw    character_215 -$
        defb    16*0+6-1
        defw    character_216 -$
        defb    16*5+6-1
        defw    character_217 -$
        defb    16*0+6-1
        defw    character_218 -$
        defb    16*0+6-1
        defw    character_219 -$
        defb    16*0+6-1
        defw    character_220 -$
        defb    16*5+6-1
        defw    character_221 -$
        defb    16*0+6-1
        defw    character_222 -$
        defb    16*0+6-1
        defw    character_223 -$
        defb    16*0+6-1
        defw    character_224 -$
        defb    16*11+6-1
        defw    character_225 -$
        defb    16*0+6-1
        defw    character_226 -$
        defb    16*0+6-1
        defw    character_227 -$
        defb    16*0+6-1
        defw    character_228 -$
        defb    16*5+6-1
        defw    character_229 -$
        defb    16*0+6-1
        defw    character_230 -$
        defb    16*0+6-1
        defw    character_231 -$
        defb    16*0+6-1
        defw    character_232 -$
        defb    16*5+6-1
        defw    character_233 -$
        defb    16*0+6-1
        defw    character_234 -$
        defb    16*0+6-1
        defw    character_235 -$
        defb    16*0+6-1
        defw    character_236 -$
        defb    16*5+6-1
        defw    character_237 -$
        defb    16*0+6-1
        defw    character_238 -$
        defb    16*0+6-1
        defw    character_239 -$
        defb    16*0+6-1
        defw    character_240 -$
        defb    16*11+6-1
        defw    character_241 -$
        defb    16*0+6-1
        defw    character_242 -$
        defb    16*0+6-1
        defw    character_243 -$
        defb    16*0+6-1
        defw    character_244 -$
        defb    16*5+6-1
        defw    character_245 -$
        defb    16*0+6-1
        defw    character_246 -$
        defb    16*0+6-1
        defw    character_247 -$
        defb    16*0+6-1
        defw    character_248 -$
        defb    16*5+6-1
        defw    character_249 -$
        defb    16*0+6-1
        defw    character_250 -$
        defb    16*0+6-1
        defw    character_251 -$
        defb    16*0+6-1
        defw    character_252 -$
        defb    16*5+6-1
        defw    character_253 -$
        defb    16*0+6-1
        defw    character_254 -$
        defb    16*0+8-1
        defw    character_255 -$
        defb    16*0+8-1
        defw    terminus -$

; --------------------------------------------------------------------------------
; definitions

space:

exclamation_mark:
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %00100000
        defb    %00100000

quotation_mark:
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000

number_sign:
        defb    %00110000
        defb    %01111000
        defb    %01001000
        defb    %01000000
        defb    %01000000
        defb    %11100000
        defb    %11100000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %11111000
        defb    %11111000

dollar_sign:
        defb    %01110000
        defb    %11111000
        defb    %10101000
        defb    %10100000
        defb    %10100000
        defb    %11110000
        defb    %01111000
        defb    %00101000
        defb    %00101000
        defb    %10101000
        defb    %11111000
        defb    %01110000

percent_sign:
        defb    %11000000
        defb    %11001000
        defb    %00001000
        defb    %00010000
        defb    %00010000
        defb    %00100000
        defb    %00100000
        defb    %01000000
        defb    %01000000
        defb    %10000000
        defb    %10011000
        defb    %00011000

ampersand:
        defb    %01100000
        defb    %11110000
        defb    %11000000
        defb    %10000000
        defb    %11010000
        defb    %01111000
        defb    %11111000
        defb    %11010000
        defb    %10010000
        defb    %11011000
        defb    %11111000
        defb    %01110000

apostrophe:
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000

left_parenthesis:
        defb    %00010000
        defb    %00110000
        defb    %00100000
        defb    %01100000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01100000
        defb    %00100000
        defb    %00110000
        defb    %00010000

right_parenthesis:
        defb    %01000000
        defb    %01100000
        defb    %00100000
        defb    %00110000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00110000
        defb    %00100000
        defb    %01100000
        defb    %01000000

asterisk:
        defb    %00100000
        defb    %00100000
        defb    %10101000
        defb    %11111000
        defb    %01110000
        defb    %00100000
        defb    %01110000
        defb    %11111000
        defb    %10101000
        defb    %00100000
        defb    %00100000
        defb    %00100000

plus_sign:
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %11111000
        defb    %11111000
        defb    %00100000
        defb    %00100000
        defb    %00100000

comma:
        defb    %00100000
        defb    %00100000
        defb    %01100000
        defb    %01000000

hyphen_minus:
        defb    %01110000
        defb    %01110000

full_stop:
        defb    %00100000
        defb    %00100000

solidus:
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01000000
        defb    %01000000
        defb    %01000000

digit_0:
        defb    %00100000
        defb    %01110000
        defb    %01110000
        defb    %11011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01110000
        defb    %01110000
        defb    %00100000

digit_1:
        defb    %00100000
        defb    %00100000
        defb    %01100000
        defb    %01100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000

digit_2:
        defb    %01110000
        defb    %11111000
        defb    %10011000
        defb    %00001000
        defb    %00011000
        defb    %00110000
        defb    %01100000
        defb    %11000000
        defb    %10000000
        defb    %10000000
        defb    %11111000
        defb    %11111000

digit_3:
        defb    %11111000
        defb    %11111000
        defb    %00001000
        defb    %00011000
        defb    %00110000
        defb    %00110000
        defb    %00011000
        defb    %00001000
        defb    %10001000
        defb    %11011000
        defb    %01111000
        defb    %01110000

digit_4:
        defb    %00010000
        defb    %00110000
        defb    %01110000
        defb    %01010000
        defb    %11010000
        defb    %10010000
        defb    %11111000
        defb    %11111000
        defb    %00010000
        defb    %00010000
        defb    %00010000
        defb    %00010000

digit_5:
        defb    %11111000
        defb    %11111000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11111000
        defb    %00011000
        defb    %00001000
        defb    %00001000
        defb    %10011000
        defb    %11111000
        defb    %01110000

digit_6:
        defb    %00110000
        defb    %01110000
        defb    %11000000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %11011000
        defb    %11111000
        defb    %01110000

digit_7:
        defb    %11111000
        defb    %11111000
        defb    %00001000
        defb    %00011000
        defb    %00010000
        defb    %00110000
        defb    %00100000
        defb    %01100000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000

digit_8:
        defb    %01110000
        defb    %11111000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %01110000
        defb    %01110000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %01110000

digit_9:
        defb    %01110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %01111000
        defb    %00011000
        defb    %00010000
        defb    %00110000
        defb    %01100000
        defb    %01100000

colon:
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00100000
        defb    %00100000
        defb    %00100000

semicolon:
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01100000
        defb    %01000000

less_than_sign:
        defb    %00010000
        defb    %00010000
        defb    %00100000
        defb    %00100000
        defb    %01000000
        defb    %10000000
        defb    %10000000
        defb    %01000000
        defb    %00100000
        defb    %00100000
        defb    %00010000
        defb    %00010000

equals_sign:
        defb    %11111000
        defb    %11111000
        defb    %00000000
        defb    %11111000
        defb    %11111000

greater_than_sign:
        defb    %01000000
        defb    %01000000
        defb    %00100000
        defb    %00100000
        defb    %00010000
        defb    %00001000
        defb    %00001000
        defb    %00010000
        defb    %00100000
        defb    %00100000
        defb    %01000000
        defb    %01000000

question_mark:
        defb    %01110000
        defb    %01110000
        defb    %11011000
        defb    %10001000
        defb    %00001000
        defb    %00011000
        defb    %00110000
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %00100000
        defb    %00100000

commercial_at:
        defb    %01110000
        defb    %11111000
        defb    %11001000
        defb    %10001000
        defb    %10111000
        defb    %10111000
        defb    %10101000
        defb    %10111000
        defb    %10011000
        defb    %11000000
        defb    %01110000
        defb    %01110000

latin_capital_letter_a:
        defb    %00100000
        defb    %01110000
        defb    %11011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %11111000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_capital_letter_b:
        defb    %11100000
        defb    %11110000
        defb    %10011000
        defb    %10001000
        defb    %10011000
        defb    %11110000
        defb    %11110000
        defb    %10011000
        defb    %10001000
        defb    %10011000
        defb    %11110000
        defb    %11100000

latin_capital_letter_c:
        defb    %01110000
        defb    %11111000
        defb    %11001000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11001000
        defb    %11111000
        defb    %01110000
zeusprinthex $
latin_capital_letter_d:
        defb    %11100000
        defb    %11110000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10011000
        defb    %11110000
        defb    %11100000

latin_capital_letter_e:
        defb    %11111000
        defb    %11111000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11110000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11111000
        defb    %11111000

latin_capital_letter_f:
        defb    %11111000
        defb    %11111000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11110000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000

latin_capital_letter_g:
        defb    %01110000
        defb    %11111000
        defb    %11001000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10011000
        defb    %10011000
        defb    %10001000
        defb    %11001000
        defb    %11111000
        defb    %01111000

latin_capital_letter_h:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %11111000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_capital_letter_i:
        defb    %01110000
        defb    %01110000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000

latin_capital_letter_j:
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %10011000
        defb    %11111000
        defb    %01110000

latin_capital_letter_k:
        defb    %10001000
        defb    %10011000
        defb    %10010000
        defb    %10110000
        defb    %11100000
        defb    %11000000
        defb    %11000000
        defb    %11100000
        defb    %10110000
        defb    %10010000
        defb    %10011000
        defb    %10001000

latin_capital_letter_l:
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11111000
        defb    %11111000

latin_capital_letter_m:
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %11111000
        defb    %10101000
        defb    %10101000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_capital_letter_n:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11001000
        defb    %11001000
        defb    %10101000
        defb    %10101000
        defb    %10011000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_capital_letter_o:
        defb    %01110000
        defb    %11111000
        defb    %11011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %11111000
        defb    %01110000

latin_capital_letter_p:
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10011000
        defb    %11111000
        defb    %11110000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000

latin_capital_letter_q:
        defb    %01110000
        defb    %11111000
        defb    %11011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10101000
        defb    %10101000
        defb    %10111000
        defb    %10010000
        defb    %11111000
        defb    %01101000

latin_capital_letter_r:
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10011000
        defb    %11110000
        defb    %11100000
        defb    %10100000
        defb    %10110000
        defb    %10011000
        defb    %10001000

latin_capital_letter_s:
        defb    %01110000
        defb    %11111000
        defb    %10001000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %01111000
        defb    %00001000
        defb    %00001000
        defb    %10011000
        defb    %11111000
        defb    %01110000

latin_capital_letter_t:
        defb    %11111000
        defb    %11111000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000

latin_capital_letter_u:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %11111000
        defb    %01110000

latin_capital_letter_v:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01010000
        defb    %01010000
        defb    %01110000
        defb    %01110000
        defb    %00100000
        defb    %00100000

latin_capital_letter_w:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10101000
        defb    %10101000
        defb    %10101000
        defb    %11111000
        defb    %11111000
        defb    %01010000
        defb    %01010000

latin_capital_letter_x:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01010000
        defb    %01110000
        defb    %00100000
        defb    %01110000
        defb    %01010000
        defb    %11011000
        defb    %10001000
        defb    %10001000

latin_capital_letter_y:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01010000
        defb    %01110000
        defb    %01110000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000

latin_capital_letter_z:
        defb    %11111000
        defb    %11111000
        defb    %00001000
        defb    %00010000
        defb    %00010000
        defb    %00100000
        defb    %00100000
        defb    %01000000
        defb    %01000000
        defb    %10000000
        defb    %11111000
        defb    %11111000

left_square_bracket:
        defb    %00100000
        defb    %01100000
        defb    %01000000
        defb    %11111000
        defb    %11111000
        defb    %01000000
        defb    %01100000
        defb    %00100000

reverse_solidus:
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10010000
        defb    %10111000
        defb    %00101000
        defb    %00001000
        defb    %00011000
        defb    %00110000
        defb    %00100000
        defb    %00111000
        defb    %00111000

right_square_bracket:
        defb    %00100000
        defb    %00110000
        defb    %00010000
        defb    %11111000
        defb    %11111000
        defb    %00010000
        defb    %00110000
        defb    %00100000

circumflex_accent:
        defb    %00100000
        defb    %01110000
        defb    %11111000
        defb    %10101000
        defb    %00100000
        defb    %00100000
        defb    %00100000

low_line:
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %11111000
        defb    %11111000
        defb    %01010000
        defb    %11111000
        defb    %11111000
        defb    %01010000
        defb    %01010000
        defb    %01010000

grave_accent:
        defb    %11111000
        defb    %11111000

latin_small_letter_a:
        defb    %01110000
        defb    %01111000
        defb    %00001000
        defb    %01111000
        defb    %11111000
        defb    %10001000
        defb    %11111000
        defb    %01111000

latin_small_letter_b:
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10011000
        defb    %11111000
        defb    %11110000

latin_small_letter_c:
        defb    %01111000
        defb    %11111000
        defb    %11000000
        defb    %10000000
        defb    %10000000
        defb    %11000000
        defb    %11111000
        defb    %01111000

latin_small_letter_d:
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %00001000
        defb    %01111000
        defb    %11111000
        defb    %11001000
        defb    %10001000
        defb    %10001000
        defb    %11001000
        defb    %11111000
        defb    %01111000

latin_small_letter_e:
        defb    %01110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %11111000
        defb    %10000000
        defb    %11110000
        defb    %01110000

latin_small_letter_f:
        defb    %00010000
        defb    %00110000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000

latin_small_letter_g:
        defb    %01111000
        defb    %11111000
        defb    %11001000
        defb    %10001000
        defb    %11001000
        defb    %11111000
        defb    %01111000
        defb    %00001000
        defb    %01111000
        defb    %01110000

latin_small_letter_h:
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_small_letter_i:
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %01100000
        defb    %01100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000

latin_small_letter_j:
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %01100000
        defb    %01100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01100000
        defb    %11000000

latin_small_letter_k:
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01001000
        defb    %01001000
        defb    %01010000
        defb    %01110000
        defb    %01100000
        defb    %01010000
        defb    %01001000
        defb    %01001000

latin_small_letter_l:
        defb    %01100000
        defb    %01100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000

latin_small_letter_m:
        defb    %11010000
        defb    %11111000
        defb    %10101000
        defb    %10101000
        defb    %10101000
        defb    %10101000
        defb    %10101000
        defb    %10101000

latin_small_letter_n:
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000

latin_small_letter_o:
        defb    %01110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %11001000
        defb    %11111000
        defb    %01110000

latin_small_letter_p:
        defb    %11110000
        defb    %11111000
        defb    %10011000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %11110000
        defb    %10000000
        defb    %10000000
        defb    %10000000

latin_small_letter_q:
        defb    %01111000
        defb    %11111000
        defb    %11001000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %01111000
        defb    %00001000
        defb    %00001000
        defb    %00001000

latin_small_letter_r:
        defb    %01011000
        defb    %01111000
        defb    %01100000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000
        defb    %01000000

latin_small_letter_s:
        defb    %01111000
        defb    %11111000
        defb    %10000000
        defb    %11110000
        defb    %01111000
        defb    %00001000
        defb    %11111000
        defb    %11110000

latin_small_letter_t:
        defb    %00100000
        defb    %00100000
        defb    %01110000
        defb    %01110000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00110000
        defb    %00010000

latin_small_letter_u:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11001000
        defb    %11111000
        defb    %01111000

latin_small_letter_v:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01010000
        defb    %01110000
        defb    %00100000
        defb    %00100000

latin_small_letter_w:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10101000
        defb    %10101000
        defb    %11111000
        defb    %11111000
        defb    %01010000

latin_small_letter_x:
        defb    %10001000
        defb    %10001000
        defb    %11011000
        defb    %01110000
        defb    %01110000
        defb    %11011000
        defb    %10001000
        defb    %10001000

latin_small_letter_y:
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %10001000
        defb    %11111000
        defb    %01111000
        defb    %00001000
        defb    %00011000
        defb    %01111000
        defb    %01110000

latin_small_letter_z:
        defb    %11111000
        defb    %11111000
        defb    %00010000
        defb    %00110000
        defb    %01100000
        defb    %01000000
        defb    %11111000
        defb    %11111000

left_curly_bracket:
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10000000
        defb    %10001000
        defb    %10011000
        defb    %00101000
        defb    %01001000
        defb    %01111000
        defb    %00001000

vertical_line:
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000
        defb    %01010000

right_curly_bracket:
        defb    %11000000
        defb    %00100000
        defb    %11000000
        defb    %00100000
        defb    %11001000
        defb    %00011000
        defb    %00101000
        defb    %01001000
        defb    %01111000
        defb    %00001000

tilde:
        defb    %00100000
        defb    %00100000
        defb    %00000000
        defb    %11111000
        defb    %11111000
        defb    %00000000
        defb    %00100000
        defb    %00100000

delete:
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000
        defb    %11111000

character_128:

character_129:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_130:
        defb    %00001100
        defb    %00001100
        defb    %00001100
        defb    %00001100

character_131:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_132:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_133:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_134:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_135:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_136:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_137:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_138:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_139:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_140:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_141:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_142:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_143:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_144:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_145:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_146:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_147:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_148:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_149:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_150:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_151:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_152:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_153:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_154:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_155:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_156:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_157:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_158:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_159:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000

character_160:

character_161:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_162:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_163:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_164:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_165:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_166:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_167:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_168:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_169:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_170:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_171:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_172:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_173:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_174:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_175:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_176:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_177:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_178:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_179:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_180:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_181:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_182:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_183:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_184:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_185:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_186:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_187:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_188:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_189:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_190:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000

character_191:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %01100000
        defb    %10100000
        defb    %10100000
        defb    %11000000

character_192:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_193:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_194:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_195:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_196:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_197:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_198:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_199:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_200:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_201:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_202:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_203:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_204:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_205:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_206:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_207:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000

character_208:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_209:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_210:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_211:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_212:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_213:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_214:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_215:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_216:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_217:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_218:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_219:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_220:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_221:
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %11000000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_222:
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_223:
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %00000000
        defb    %11011000
        defb    %11011000
        defb    %11011000
        defb    %11011000

character_224:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_225:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_226:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_227:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_228:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_229:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_230:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_231:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_232:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_233:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_234:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_235:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_236:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_237:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_238:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_239:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100

character_240:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_241:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_242:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_243:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %00000000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_244:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_245:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_246:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %00100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_247:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_248:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_249:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_250:
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_251:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %00011100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_252:
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_253:
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11100000
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100
        defb    %11111100

character_254:
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %00001111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111

character_255:
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111
        defb    %11111111

terminus:
