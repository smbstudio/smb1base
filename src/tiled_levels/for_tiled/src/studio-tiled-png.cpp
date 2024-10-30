#include <iostream>
#include <fstream>
#include <string>
#include <array>
#include "fpng.h"
using namespace std;

struct Metatile {
	unsigned char tiles[4];
	int pal;
	string name;
};

class Image {
private:
	const unsigned char m_nesPalette[192] = {
		0x62, 0x62, 0x62, 0x00, 0x2C, 0x7C, 0x11, 0x15, 0x9C, 0x36, 0x03, 0x9C,
		0x55, 0x00, 0x7C, 0x67, 0x00, 0x44, 0x67, 0x07, 0x03, 0x55, 0x1C, 0x00,
		0x36, 0x32, 0x00, 0x11, 0x44, 0x00, 0x00, 0x4E, 0x00, 0x00, 0x4C, 0x03,
		0x00, 0x40, 0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xAB, 0xAB, 0xAB, 0x12, 0x60, 0xCE, 0x3D, 0x42, 0xFA, 0x6E, 0x29, 0xFA,
		0x99, 0x1C, 0xCE, 0xB1, 0x1E, 0x81, 0xB1, 0x2F, 0x29, 0x99, 0x4A, 0x00,
		0x6E, 0x69, 0x00, 0x3D, 0x82, 0x00, 0x12, 0x8F, 0x00, 0x00, 0x8D, 0x29,
		0x00, 0x7C, 0x81, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xFF, 0xFF, 0xFF, 0x60, 0xB2, 0xFF, 0x8D, 0x92, 0xFF, 0xC0, 0x78, 0xFF,
		0xEC, 0x6A, 0xFF, 0xFF, 0x6D, 0xD4, 0xFF, 0x7F, 0x79, 0xEC, 0x9B, 0x2A,
		0xC0, 0xBA, 0x00, 0x8D, 0xD4, 0x00, 0x60, 0xE2, 0x2A, 0x47, 0xE0, 0x79,
		0x47, 0xCE, 0xD4, 0x4E, 0x4E, 0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
		0xFF, 0xFF, 0xFF, 0xBF, 0xE0, 0xFF, 0xD1, 0xD3, 0xFF, 0xE6, 0xC9, 0xFF,
		0xF7, 0xC3, 0xFF, 0xFF, 0xC4, 0xEE, 0xFF, 0xCB, 0xC9, 0xF7, 0xD7, 0xA9,
		0xE6, 0xE3, 0x97, 0xD1, 0xEE, 0x97, 0xBF, 0xF3, 0xA9, 0xB5, 0xF2, 0xC9,
		0xB5, 0xEB, 0xEE, 0xB8, 0xB8, 0xB8, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	};
	char* m_data;
	int m_width;
	int m_X = 0;
	int m_Y = 0;
public:
	Image(size_t length, size_t width) {
		m_width = width;
		m_data = new char[length];
		for (int i = 0; i < length; i++) m_data[i] = 0;
	}
	~Image() {
		delete[] m_data;
	}
	//-1 means invisible pixel
	void write(int nesPalValue) {
		int index = 4 * (m_X + m_Y * m_width);
		if (nesPalValue < 0) {
			for (int i = 0; i < 4; i++) m_data[index + i] = 0;
			return;
		}
		int pal = 3 * (nesPalValue & 0x0f + 16 * (nesPalValue >> 4));
		m_data[index+0] = m_nesPalette[pal];
		m_data[index+1] = m_nesPalette[pal+1];
		m_data[index+2] = m_nesPalette[pal+2];
		m_data[index+3] = 0xff;
	}
	void moveX(int amount) {
		m_X += amount;
		while (m_X >= m_width) m_X -= m_width;
		while (m_X < 0) m_X += m_width;
	}
	void moveY(int amount) {
		m_Y += amount;
	}
	char* data() {
		return m_data;
	}
};

int main(int argc, char* argv[])
{
	if (argc < 4) {
		cout << "Usage: [CHR file (min.4kb)] [Palette file (32 bytes)] [Metatiles definition assembly file]";
		return -1;
	}

	ifstream fChr(argv[1], ios::in | ios::binary);
	fChr.seekg(0, ios::end);
	if (fChr.tellg() < 0x1000) {
		cout << "error: CHR below 4 kB";
		return -1;
	}
	char chr[0x1000];
	fChr.seekg(0, ios::beg);
	fChr.read(chr, 0x1000);

	ifstream fPalette(argv[2], ios::in | ios::binary);
	fPalette.seekg(0, ios::end);
	if (fPalette.tellg() < 0x20) {
		cout << "error: palette file is not 32 bytes";
		return -1;
	}
	char palette[0x20];
	fPalette.seekg(0, ios::beg);
	fPalette.read(palette, 0x20);

	ifstream fMetatiles(argv[3]);
	string fMetatilesStr((std::istreambuf_iterator<char>(fMetatiles)), istreambuf_iterator<char>());
	fMetatiles.close();

	int numMetatiles = 0;
	int pos = fMetatilesStr.find("DefineMTile \"");
	Metatile metatiles[256];
	while (numMetatiles < 256 && pos < fMetatilesStr.size()) 
	{
		int s = fMetatilesStr.find("\"", pos);
		int e = fMetatilesStr.find("\"", s + 1);
		metatiles[numMetatiles].name = fMetatilesStr.substr(s + 1, e - s - 1);
		for (int i = 0; i < 4; i++)
		{
			pos = fMetatilesStr.find("$", pos+1);
			metatiles[numMetatiles].tiles[i] = stoi(fMetatilesStr.substr(pos + 1, 2), nullptr, 16);
		}
		metatiles[numMetatiles].pal = stoi(fMetatilesStr.substr(fMetatilesStr.find("pal", pos + 1) + 3, 1));
		numMetatiles++;
		pos = fMetatilesStr.find("DefineMTile \"", pos + 1);
	}

	int imgSize = 4 * 16 * 16 * 16 * 16;
	Image image(imgSize, 256);

	for (int metatile = 0; metatile < numMetatiles; metatile++)
	{
		Metatile& thisMetatile = metatiles[metatile];
		for (int tile = 0; tile < 4; tile++)
		{
			int tileOffs = thisMetatile.tiles[tile] * 16;
			for (int tilePixelY = 0; tilePixelY < 8; tilePixelY++) {
				for (int tilePixelX = 0; tilePixelX < 8; tilePixelX++) {
					int tileValue = (chr[tileOffs + tilePixelY] >> (7 - tilePixelX)) & 0b01;
					tileValue += ((chr[tileOffs + tilePixelY + 8] >> (7 - tilePixelX)) << 1) & 0b10;

					// this makes pixels that use palette 0 be transparent in the png
					if (tileValue == 0) 
						image.write(-1);
					else 
						image.write(palette[4 * thisMetatile.pal + tileValue]);

					image.moveX(1);
				}
				image.moveX(-8);
				image.moveY(1);
			}
			if (tile == 1 || tile == 3) {
				image.moveX(8);
				image.moveY(-16);
			}
		}
		if ((metatile & 0x0f) == 0x0f) {
			image.moveY(16);
		}
	}

	fpng::fpng_init();
	fpng::fpng_encode_image_to_file("tiled.png", image.data(), 256, 256, 4);

	ofstream tsxFile("USE_THIS.tsx");
	tsxFile << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<tileset version=\"1.10\" tiledversion=\"1.10.2\" name=\"tiled\" tilewidth=\"16\" tileheight=\"16\" tilecount=\"256\" columns=\"16\">\n <image source=\"tiled.png\" width=\"256\" height=\"256\"/>";
	for (int i = 0; i < numMetatiles; i++) {
		tsxFile << "\n <tile id=\"" << i << "\" type=\"" << metatiles[i].name << "\"/>";
	}
	tsxFile << "\n</tileset>";
}
