shader_type canvas_item;

uniform sampler2D tex_feher : source_color, repeat_enable, filter_nearest;
uniform sampler2D tex_piros : source_color, repeat_enable, filter_nearest;
uniform sampler2D tex_kek : source_color, repeat_enable, filter_nearest;
uniform sampler2D tex_zold : source_color, repeat_enable, filter_nearest;

uniform vec2 pattern_size = vec2(1280.0, 720.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.2; // Ezzel állíthatod az éleket

varying vec2 world_pixel_pos;

void vertex() {
    world_pixel_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 tile_tex = texture(TEXTURE, UV);
    
    // Világkoordináta alapú UV a háttérhez
    vec2 kavalkad_uv = mod(world_pixel_pos, pattern_size) / pattern_size;
    
    // Színek beolvasása
    vec3 c_feher = texture(tex_feher, kavalkad_uv).rgb;
    vec3 c_piros = texture(tex_piros, kavalkad_uv).rgb;
    vec3 c_kek   = texture(tex_kek, kavalkad_uv).rgb;
    vec3 c_zold  = texture(tex_zold, kavalkad_uv).rgb;

    // Színmaszkok kiszámítása távolság alapján (smoothabb átmenet)
    float m_feher = step(distance(tile_tex.rgb, vec3(1.0, 1.0, 1.0)), tolerance);
    float m_piros = step(distance(tile_tex.rgb, vec3(1.0, 0.0, 0.0)), tolerance);
    float m_zold  = step(distance(tile_tex.rgb, vec3(0.0, 1.0, 0.0)), tolerance);
    float m_kek   = step(distance(tile_tex.rgb, vec3(0.0, 0.0, 1.0)), tolerance);
    
    // Árnyék/Szürke detektálás
    float grayscale = (tile_tex.r + tile_tex.g + tile_tex.b) / 3.0;
    // Akkor árnyék, ha nem fekete és nem a fenti színek egyike
    float is_any_color = clamp(m_feher + m_piros + m_zold + m_kek, 0.0, 1.0);
    float m_shadow = (1.0 - is_any_color) * step(0.05, grayscale);

    // Összeállítás
    vec3 final_rgb = vec3(0.0);
    
    // A maszkok alapján hozzáadjuk a megfelelő színeket
    final_rgb = mix(final_rgb, c_feher, m_feher);
    final_rgb = mix(final_rgb, c_piros, m_piros);
    final_rgb = mix(final_rgb, c_zold, m_zold);
    final_rgb = mix(final_rgb, c_kek, m_kek);
    
    // Árnyékolt rész (a fehér hátteret sötétítjük a szürkével)
    vec3 shadow_color = c_feher * grayscale;
    final_rgb = mix(final_rgb, shadow_color, m_shadow);
    
    // Körvonal (fekete rész) megtartása
    float is_line = 1.0 - clamp(is_any_color + m_shadow, 0.0, 1.0);
    final_rgb = mix(final_rgb, tile_tex.rgb, is_line);

    COLOR = vec4(final_rgb, tile_tex.a);
}