#ifndef SCREEN_OPTIONS_MASTER_PREFS_H
#define SCREEN_OPTIONS_MASTER_PREFS_H

static const int MAX_OPTIONS = 16;
#define OPT_SAVE_PREFERENCES (1 << 0)
#define OPT_APPLY_GRAPHICS (1 << 1)
#define OPT_APPLY_THEME (1 << 2)
#define OPT_CHANGE_GAME (1 << 3)
#define OPT_APPLY_SOUND (1 << 4)
#define OPT_APPLY_SONG (1 << 5)
#define OPT_APPLY_ASPECT_RATIO (1 << 6)

struct ConfOption
{
	static struct ConfOption* Find(RString name);

	// Name of this option.
	RString name;

	// Name of the preference this option affects.
	RString m_sPrefName;

	using MoveData_t = void (*)(int&, bool, const ConfOption*);
	MoveData_t MoveData;
	int m_iEffects;
	bool m_bAllowThemeItems;

	/* For dynamic options, update the options. Since this changes the available
	 * options, this may invalidate the offsets returned by Get() and Put(). */
	void UpdateAvailableOptions();

	/* Return the list of available selections; Get() and Put() use indexes into
	 * this array. UpdateAvailableOptions() should be called before using this.
	 */
	void MakeOptionsList(vector<RString>& out) const;

	inline int Get() const
	{
		int sel;
		MoveData(sel, true, this);
		return sel;
	}
	inline void Put(int sel) const { MoveData(sel, false, this); }
	int GetEffects() const;

	ConfOption(const char* n,
			   MoveData_t m,
			   const char* c0 = NULL,
			   const char* c1 = NULL,
			   const char* c2 = NULL,
			   const char* c3 = NULL,
			   const char* c4 = NULL,
			   const char* c5 = NULL,
			   const char* c6 = NULL,
			   const char* c7 = NULL,
			   const char* c8 = NULL,
			   const char* c9 = NULL,
			   const char* c10 = NULL,
			   const char* c11 = NULL,
			   const char* c12 = NULL,
			   const char* c13 = NULL,
			   const char* c14 = NULL,
			   const char* c15 = NULL,
			   const char* c16 = NULL,
			   const char* c17 = NULL,
			   const char* c18 = NULL,
			   const char* c19 = NULL)
	{
		name = n;
		m_sPrefName = name; // copy from name (not n), to allow refcounting
		MoveData = m;
		MakeOptionsListCB = NULL;
		m_iEffects = 0;
		m_bAllowThemeItems = true;
#define PUSH(c)                                                                \
	if (c)                                                                     \
		names.push_back(c);
		PUSH(c0);
		PUSH(c1);
		PUSH(c2);
		PUSH(c3);
		PUSH(c4);
		PUSH(c5);
		PUSH(c6);
		PUSH(c7);
		PUSH(c8);
		PUSH(c9);
		PUSH(c10);
		PUSH(c11);
		PUSH(c12);
		PUSH(c13);
		PUSH(c14);
		PUSH(c15);
		PUSH(c16);
		PUSH(c17);
		PUSH(c18);
		PUSH(c19);
	}
	void AddOption(const RString& sName) { PUSH(sName); }
#undef PUSH

	ConfOption(const char* n, MoveData_t m, void (*lst)(vector<RString>& out))
	{
		name = n;
		MoveData = m;
		MakeOptionsListCB = lst;
		m_iEffects = 0;
		m_bAllowThemeItems = false; // don't theme dynamic choices
	}

	// private:
	vector<RString> names;
	void (*MakeOptionsListCB)(vector<RString>& out);
};

#endif