// Landform rule data for LDtk tooling

const LANDFORM_DIRS = { N: 0x01, NE: 0x02, E: 0x04, SE: 0x08, S: 0x10, SW: 0x20, W: 0x40, NW: 0x80 };

const LANDFORM_SLOTS = [
  "top_left", "top", "top_right",
  "left", "center", "right",
  "bottom_left", "bottom", "bottom_right",
  "inner_tl", "inner_tr", "inner_bl", "inner_br",
];
const LANDFORM_SLOT_COUNT = LANDFORM_SLOTS.length;

// The next simpler slot to try when a set leaves a slot undefined.
// everything ends with center which is basically the regular metatile
const LANDFORM_FALLBACK = {
  top_left: "top", top_right: "top",
  bottom_left: "bottom", bottom_right: "bottom",
  top: "center", bottom: "center", left: "center", right: "center",
  inner_tl: "center", inner_tr: "center", inner_bl: "center", inner_br: "center",
};

function landformSlotName(mask) {
  const has = dir => (mask & LANDFORM_DIRS[dir]) !== 0;
  const row = !has("N") ? "top" : !has("S") ? "bottom" : "mid";
  const col = !has("W") && has("E") ? "left" : has("W") && !has("E") ? "right" : "center";
  if (row === "mid") {
    // A 1-wide pillar is also mid/center but has no inner corners
    if (col !== "center" || !has("W")) return col;
    if (!has("NW")) return "inner_tl";
    if (!has("NE")) return "inner_tr";
    if (!has("SW")) return "inner_bl";
    if (!has("SE")) return "inner_br";
    return "center";
  }
  return col === "center" ? row : `${row}_${col}`;
}

// 256-entry neighbor mask -> slot index table
function landformSlotLut() {
  return Array.from({ length: 256 }, (_, m) => LANDFORM_SLOTS.indexOf(landformSlotName(m)));
}

// Validates the parsed "landforms" array against the set of defined metatile ids.
// Returns one fully resolved LANDFORM_SLOT_COUNT-entry metatile array per set.
function landformBuildSets(sets, metatileIds) {
  if (!Array.isArray(sets)) throw new Error('metatiles.json "landforms" must be an array of sets');
  if (sets.length > 256) throw new Error('metatiles.json "landforms" has more than 256 sets');
  return sets.map((set, index) => {
    const name = typeof set?.name === "string" ? ` (${set.name})` : "";
    const fail = message => {
      throw new Error(`metatiles.json landform set ${index}${name}: ${message}`);
    };
    if (set === null || typeof set !== "object" || Array.isArray(set)) fail("expected an object");
    for (const field of ["id", "name", "tiles"]) {
      if (!Object.hasOwn(set, field)) fail(`missing field "${field}"`);
    }
    if (set.id !== index) fail("id must equal the set's position in the array");
    if (typeof set.name !== "string" || !set.name.trim()) fail("name must be a nonempty string");
    const tiles = set.tiles;
    if (tiles === null || typeof tiles !== "object" || Array.isArray(tiles)) {
      fail("tiles must be an object mapping slot names to metatile ids");
    }
    for (const [slot, tile] of Object.entries(tiles)) {
      if (!LANDFORM_SLOTS.includes(slot)) fail(`tiles has unknown slot "${slot}"`);
      if (!Number.isInteger(tile) || !metatileIds.has(tile)) {
        fail(`tiles.${slot} ${JSON.stringify(tile)} is not a defined metatile id`);
      }
    }
    if (!Object.hasOwn(tiles, "center")) fail('tiles must define "center"');
    return LANDFORM_SLOTS.map(slot => {
      while (!Object.hasOwn(tiles, slot)) slot = LANDFORM_FALLBACK[slot];
      return tiles[slot];
    });
  });
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    LANDFORM_DIRS, LANDFORM_SLOTS, LANDFORM_SLOT_COUNT, LANDFORM_FALLBACK,
    landformSlotName, landformSlotLut, landformBuildSets,
  };
}
